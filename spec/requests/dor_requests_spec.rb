# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DOR' do
  let(:druid) { 'druid:bc123df5678' }

  describe 'reindexing' do
    before do
      allow(Logger).to receive(:new).and_return(mock_logger)
      allow(RSolr).to receive(:connect).and_return(mock_solr_conn)
      allow(DocumentBuilder).to receive(:for).with(model: cocina).and_return(mock_indexer)
      allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_service)
    end

    let(:mock_logger) { instance_double(Logger, :formatter= => true, info: true) }
    let(:mock_solr_conn) { instance_double(RSolr::Client, add: true, commit: true) }
    let(:cocina) { instance_double(Cocina::Models::DROWithMetadata, externalIdentifier: druid) }
    let(:object_service) { instance_double(Dor::Services::Client::Object, find: cocina) }
    let(:mock_indexer) { instance_double(CompositeIndexer::Instance, to_solr: mock_solr_doc) }
    let(:mock_solr_doc) { { id: druid, text_field_tesim: 'a field to be searched' } }

    describe 'POST #reindex' do
      it 'reindexes an object with default commitWithin param and a hard commit' do
        post "/dor/reindex/#{druid}"
        expect(mock_solr_conn).to have_received(:add).with({ id: druid, text_field_tesim: 'a field to be searched' }, add_attributes: { commitWithin: 1000 })
        expect(mock_solr_conn).to have_received(:commit)
        expect(response.body).to eq "Successfully updated index for #{druid}"
        expect(response).to have_http_status :ok
      end

      it 'reindexes an object with specified commitWithin param and no hard commit' do
        post "/dor/reindex/#{druid}", params: { commitWithin: 10_000 }
        expect(mock_solr_conn).to have_received(:add).with({ id: druid, text_field_tesim: 'a field to be searched' }, add_attributes: { commitWithin: 10_000 })
        expect(mock_solr_conn).not_to have_received(:commit)
        expect(response.body).to eq "Successfully updated index for #{druid}"
        expect(response).to have_http_status :ok
      end

      it 'can be used with asynchronous commits' do
        post "/dor/reindex/#{druid}", params: { commitWithin: 2 }
        expect(mock_solr_conn).to have_received(:add)
        expect(mock_solr_conn).not_to have_received(:commit)
        expect(response.body).to eq "Successfully updated index for #{druid}"
        expect(response).to have_http_status :ok
      end

      it 'gives the right status if an object is not found' do
        allow(object_service).to receive(:find).and_raise(Dor::Services::Client::NotFoundResponse)
        post "/dor/reindex/#{druid}"
        expect(response.body).to eq 'Object does not exist in the repository'
        expect(response).to have_http_status :not_found
      end

      it 'raises an error for UnexpectedResponse' do
        allow(object_service).to receive(:find).and_raise(Dor::Services::Client::UnexpectedResponse.new(response: '',
                                                                                                        errors: [{ title: 'Oops!' }]))
        expect { post "/dor/reindex/#{druid}" }.to raise_error Dor::Services::Client::UnexpectedResponse
      end

      it 'raises for other errors' do
        allow(object_service).to receive(:find).and_raise(Faraday::ConnectionFailed)
        expect { post "/dor/reindex/#{druid}" }.to raise_error(Faraday::ConnectionFailed)
      end
    end

    describe 'PUT #reindex_from_cocina' do
      let(:cocina_hash) { { some: 'json' } }
      let(:cocina_json) { cocina_hash.to_json }
      let(:created_at) { '2022-02-27T07:00:00.000+00:00' }
      let(:updated_at) { '2022-02-28T07:00:00.000+00:00' }

      before do
        allow(Cocina::Models).to receive(:with_metadata).with(cocina, String, created: DateTime.parse(created_at), modified: DateTime.parse(updated_at)).and_return(cocina)
      end

      it 'uses the provided cocina without hitting dor-services-app' do
        allow(Cocina::Models).to receive(:build).with(cocina_hash).and_return(cocina) # pretend our bogus test JSON is valid
        put '/dor/reindex_from_cocina',
            params: { cocina_object: cocina_hash, created_at:, updated_at: }.to_json,
            headers: { 'CONTENT_TYPE' => 'application/json' }
        expect(response.body).to eq "Successfully updated index for #{druid}"
        expect(response).to have_http_status :ok
        expect(mock_solr_conn).to have_received(:add).with(mock_solr_doc, add_attributes: { commitWithin: 1000 })
        expect(object_service).not_to have_received(:find)
      end

      it 'reindexes an object with specified commitWithin param and no hard commit' do
        allow(Cocina::Models).to receive(:build).with(cocina_hash).and_return(cocina) # pretend our bogus test JSON is valid
        put '/dor/reindex_from_cocina',
            params: { cocina_object: cocina_hash, created_at:, updated_at:, commitWithin: 10_000 }.to_json,
            headers: { 'CONTENT_TYPE' => 'application/json' }
        expect(response.body).to eq "Successfully updated index for #{druid}"
        expect(response).to have_http_status :ok
        expect(mock_solr_conn).to have_received(:add).with(mock_solr_doc, add_attributes: { commitWithin: 10_000 })
        expect(mock_solr_conn).not_to have_received(:commit)
      end

      it 'requires both the cocina json and the created_at/updated_at metadata' do
        put '/dor/reindex_from_cocina',
            params: { cocina_object: cocina_hash, updated_at: }.to_json,
            headers: { 'CONTENT_TYPE' => 'application/json' }
        expect(response).to have_http_status :bad_request
        expect(response.body).to match(/missing required parameters: created_at/)
      end

      it 'provides the caller with a useful error if invalid cocina is provided' do
        # Cocina::Models.build will be called with our bogus JSON, which will throw an error
        allow(Honeybadger).to receive(:notify).and_call_original # and_call_original used here to detect bugs around https://github.com/rails/rails/issues/43922
        put '/dor/reindex_from_cocina',
            params: { cocina_object: cocina_hash, created_at:, updated_at: }.to_json,
            headers: { 'CONTENT_TYPE' => 'application/json' }
        expect(response).to have_http_status :unprocessable_entity # the caller should've provided valid Cocina JSON
        expect(response.body).to eq "Error building Cocina model from json: 'Type field not found'; cocina=#{cocina_json}"
        expect(Honeybadger).to have_received(:notify) do |msg, context:, backtrace:|
          expect(msg).to eq 'Error building Cocina model'
          expect(context).to eq({ cocina: cocina_hash, build_error: 'Type field not found' })
          expect(backtrace).to include(/cocina-models/)
        end
      end
    end
  end

  describe '#delete_from_index' do
    let(:mock_solr_conn) { instance_double(RSolr::Client, delete_by_id: true, commit: true) }

    before do
      allow(RSolr).to receive(:connect).and_return(mock_solr_conn)
    end

    it 'removes an object from the index' do
      post "/dor/delete_from_index/#{druid}"
      expect(mock_solr_conn).to have_received(:delete_by_id).once.with(druid, commitWithin: 1000)
      expect(mock_solr_conn).to have_received(:commit).once
    end

    it 'passes through the commitWithin parameter' do
      post "/dor/delete_from_index/#{druid}", params: { commitWithin: 5000 }
      expect(mock_solr_conn).to have_received(:delete_by_id).once.with(druid, commitWithin: 5000)
      expect(mock_solr_conn).not_to have_received(:commit)
    end
  end
end
