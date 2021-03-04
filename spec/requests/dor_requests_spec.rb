# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DOR', type: :request do
  let(:druid) { 'druid:bc123df5678' }

  describe 'POST #reindex' do
    before do
      allow(Logger).to receive(:new).and_return(mock_logger)
      allow(ActiveFedora.solr).to receive(:conn).and_return(mock_solr_conn)
      allow(Dor).to receive(:find).with(druid).and_return(mock_af_doc)
      allow(Indexer).to receive(:for).with(mock_af_doc, cocina_with_metadata: Success([cocina, metadata])).and_return(mock_indexer)
      allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_service)
    end

    let(:mock_logger) { instance_double(Logger, :formatter= => true, info: true) }
    let(:mock_solr_conn) { instance_double(RSolr::Client, add: true, commit: true) }
    let(:mock_af_doc) { Dor::Item.new }
    let(:metadata) { {} }
    let(:cocina) { instance_double(Cocina::Models::DRO) }
    let(:object_service) { instance_double(Dor::Services::Client::Object, find_with_metadata: [cocina, metadata]) }
    let(:mock_indexer) { instance_double(CompositeIndexer::Instance, to_solr: mock_solr_doc) }
    let(:mock_solr_doc) { { id: druid, text_field_tesim: 'a field to be searched' } }

    it 'reindexes an object with default commitWithin param and a hard commit' do
      post "/dor/reindex/#{druid}"
      expect(mock_solr_conn).to have_received(:add).with({ id: druid, text_field_tesim: 'a field to be searched' }, add_attributes: { commitWithin: 1000 })
      expect(mock_solr_conn).to have_received(:commit)
      expect(response.body).to eq "Successfully updated index for #{druid}"
      expect(response.code).to eq '200'
    end

    it 'reindexes an object with specified commitWithin param and no hard commit' do
      post "/dor/reindex/#{druid}", params: { commitWithin: 10_000 }
      expect(mock_solr_conn).to have_received(:add).with({ id: druid, text_field_tesim: 'a field to be searched' }, add_attributes: { commitWithin: 10_000 })
      expect(mock_solr_conn).not_to have_received(:commit)
      expect(response.body).to eq "Successfully updated index for #{druid}"
      expect(response.code).to eq '200'
    end

    it 'can be used with asynchronous commits' do
      post "/dor/reindex/#{druid}", params: { commitWithin: 2 }
      expect(mock_solr_conn).to have_received(:add)
      expect(mock_solr_conn).not_to have_received(:commit)
      expect(response.body).to eq "Successfully updated index for #{druid}"
      expect(response.code).to eq '200'
    end

    it 'gives the right status if an object is not found' do
      allow(Dor).to receive(:find).and_raise(ActiveFedora::ObjectNotFoundError)
      post "/dor/reindex/#{druid}"
      expect(response.body).to eq 'Object does not exist in Fedora.'
      expect(response.code).to eq '404'
    end
  end

  describe '#delete_from_index' do
    it 'removes an object from the index' do
      allow(ActiveFedora.solr.conn).to receive(:delete_by_id)
      allow(ActiveFedora.solr.conn).to receive(:commit)
      post "/dor/delete_from_index/#{druid}"
      expect(ActiveFedora.solr.conn).to have_received(:delete_by_id).once.with(druid, commitWithin: 1000)
      expect(ActiveFedora.solr.conn).to have_received(:commit).once
    end

    it 'passes through the commitWithin parameter' do
      allow(ActiveFedora.solr.conn).to receive(:delete_by_id)
      allow(ActiveFedora.solr.conn).to receive(:commit)
      post "/dor/delete_from_index/#{druid}", params: { commitWithin: 5000 }
      expect(ActiveFedora.solr.conn).to have_received(:delete_by_id).once.with(druid, commitWithin: 5000)
      expect(ActiveFedora.solr.conn).not_to have_received(:commit)
    end
  end

  describe '#queue_size' do
    let(:mock_status) { instance_double(QueueStatus::All, queue_size: 15) }

    it 'retrives the size of the backing message queues' do
      allow(QueueStatus).to receive(:all).and_return(mock_status)
      get '/dor/queue_size'
      expect(QueueStatus).to have_received(:all).once
      expect(JSON.parse(response.body)).to include('value' => 15)
    end
  end
end
