# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ObjectProfileIndexer do
  let(:obj) do
    Dor::Item.new(label: 'test label')
  end
  let(:cocina) { Success(instance_double(Cocina::Models::DRO)) }

  describe '#to_solr' do
    let(:indexer) do
      CompositeIndexer.new(
        described_class
      ).new(id: 'druid:ab123cd4567', resource: obj, cocina: cocina)
    end
    let(:doc) { indexer.to_solr }

    it 'makes a solr doc' do
      expect(doc).to match a_hash_including(
        'obj_label_tesim' => ['test label'],
        'obj_label_ssim' => ['test label']
      )
    end
  end
end
