# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EtdPropertiesDatastreamIndexer do
  let(:obj) do
    Etd.new.tap do |obj|
      obj.properties.title = 'hello'
    end
  end

  let(:indexer) do
    described_class.new(resource: obj)
  end

  describe '#to_solr' do
    let(:indexer) do
      CompositeIndexer.new(
        described_class
      ).new(resource: obj)
    end
    let(:doc) { indexer.to_solr }

    it 'makes a solr doc' do
      expect(doc).to match a_hash_including('title_tesim' => 'hello')
    end
  end
end
