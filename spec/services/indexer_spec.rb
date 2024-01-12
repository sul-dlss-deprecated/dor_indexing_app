# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Indexer do
  let(:solr) { instance_double(RSolr::Client, add: true, delete_by_id: true) }
  let(:identifier) { 'druid:bc123df4567' }
  let(:doc) { instance_double(Hash) }
  let(:model) { instance_double(Cocina::Models::DROWithMetadata, externalIdentifier: identifier) }

  before do
    allow(DorIndexing).to receive(:build).and_return(doc)
  end

  describe '#load_and_build' do
    subject(:load_and_build) { described_class.load_and_build(identifier:) }

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    context 'when object is found' do
      let(:object_client) { instance_double(Dor::Services::Client::Object, find: model) }

      it 'is properly indexed' do
        expect(load_and_build).to eq(doc)
        expect(DorIndexing).to have_received(:build).with(cocina_with_metadata: model, workflow_client: Dor::Workflow::Client, cocina_repository: CocinaRepository)
      end
    end

    context 'when object is not found' do
      let(:object_client) { instance_double(Dor::Services::Client::Object) }

      before do
        allow(object_client).to receive(:find).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'raises an exception' do
        expect { load_and_build }.to raise_error Dor::Services::Client::NotFoundResponse
      end
    end

    context 'when unexpected response' do
      let(:object_client) { instance_double(Dor::Services::Client::Object) }

      before do
        allow(object_client).to receive(:find).and_raise(Dor::Services::Client::UnexpectedResponse.new(response: nil))
      end

      it 'raises an exception' do
        expect { load_and_build }.to raise_error Dor::Services::Client::UnexpectedResponse
      end
    end
  end

  describe '#load_and_index' do
    subject(:load_and_index) { described_class.load_and_index(solr:, identifier:) }

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    context 'when object is found' do
      let(:object_client) { instance_double(Dor::Services::Client::Object, find: model) }

      it 'is properly indexed' do
        expect(load_and_index).to eq(doc)
        expect(DorIndexing).to have_received(:build).with(cocina_with_metadata: model, workflow_client: Dor::Workflow::Client, cocina_repository: CocinaRepository)
        expect(solr).to have_received(:add).with(doc, { add_attributes: { commitWithin: 1000 } })
      end
    end

    context 'when object is not found' do
      let(:object_client) { instance_double(Dor::Services::Client::Object) }

      before do
        allow(object_client).to receive(:find).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'does not update the druid' do
        expect { load_and_index }.to raise_error Dor::Services::Client::NotFoundResponse
        expect(solr).not_to have_received(:add)
      end
    end

    context 'when unexpected response' do
      let(:object_client) { instance_double(Dor::Services::Client::Object) }

      before do
        allow(object_client).to receive(:find).and_raise(Dor::Services::Client::UnexpectedResponse.new(response: nil))
      end

      it 'does not update the druid' do
        expect { load_and_index }.to raise_error Dor::Services::Client::UnexpectedResponse
        expect(solr).not_to have_received(:add)
      end
    end
  end

  describe '#reindex' do
    subject(:reindex) { described_class.reindex(solr:, cocina_with_metadata: model) }

    it 'updates solr' do
      expect(reindex).to eq(doc)
      expect(DorIndexing).to have_received(:build).with(cocina_with_metadata: model, workflow_client: Dor::Workflow::Client, cocina_repository: CocinaRepository)
      expect(solr).to have_received(:add).with(doc, { add_attributes: { commitWithin: 1000 } })
    end
  end

  describe '#delete' do
    subject(:delete) { described_class.delete(solr:, identifier:) }

    it 'updates solr' do
      delete
      expect(solr).to have_received(:delete_by_id).with(identifier, commitWithin: 1000)
    end
  end
end
