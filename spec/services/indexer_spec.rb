# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Indexer do
  subject(:instance) { described_class.new(solr: solr, identifier: identifier) }

  let(:solr) { instance_double(RSolr::Client, add: true) }
  let(:identifier) { 'druid:bc123df4567' }

  describe '#load_and_index' do
    subject(:load_and_index) { instance.load_and_index }

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    context 'when object is found' do
      let(:doc_builder) { instance_double(CompositeIndexer::Instance, to_solr: doc) }
      let(:doc) { instance_double(Hash) }
      let(:model) { instance_double(Object) }
      let(:object_client) { instance_double(Dor::Services::Client::Object, find: model) }

      before do
        allow(DocumentBuilder).to receive(:for).and_return(doc_builder)
      end

      it 'works' do
        load_and_index
        expect(DocumentBuilder).to have_received(:for).with(model: model)
        expect(doc_builder).to have_received(:to_solr)
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
      end
    end
  end
end
