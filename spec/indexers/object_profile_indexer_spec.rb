# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ObjectProfileIndexer do
  let(:obj) do
    Dor::Item.new
  end

  let(:indexer) do
    described_class.new(resource: obj)
  end

  let(:rubydora_obj) do
    instance_double(Rubydora::DigitalObject, profile: profile)
  end

  let(:profile) do
    { 'objLabel' => 'test label' }
  end

  before do
    allow(obj).to receive(:inner_object).and_return(rubydora_obj)
  end

  describe '#to_solr' do
    let(:indexer) do
      CompositeIndexer.new(
        described_class
      ).new(resource: obj)
    end
    let(:doc) { indexer.to_solr }

    it 'makes a solr doc' do
      expect(doc).to match a_hash_including('obj_label_tesim' => ['test label'])
    end
  end
end
