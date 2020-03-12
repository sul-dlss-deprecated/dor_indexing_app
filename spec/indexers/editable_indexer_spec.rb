# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EditableIndexer do
  subject(:indexer) do
    described_class.new(resource: obj, cocina: cocina)
  end

  let(:obj) do
    instance_double(Dor::AdminPolicyObject,
                    default_rights: 'world',
                    use_license: 'by-nc-sa')
  end

  let(:cocina) { instance_double(Cocina::Models::DRO) }

  describe '#default_rights_for_indexing' do
    it 'uses the OM template if the ds is empty' do
      expect(indexer.default_rights_for_indexing).to eq('World')
    end
  end

  describe '#to_solr' do
    let(:indexer) do
      CompositeIndexer.new(
        described_class
      ).new(resource: obj, cocina: cocina)
    end
    let(:doc) { indexer.to_solr }

    before do
      allow(obj).to receive(:agreement).and_return('druid:agreement')
      allow(obj).to receive(:agreement_object).and_return(true)
    end

    it 'makes a solr doc' do
      expect(doc).to match a_hash_including('default_rights_ssim' => ['World']) # note that this is capitalized, because it comes from default_rights_for_indexing
      expect(doc).to match a_hash_including('agreement_ssim'      => ['druid:agreement'])
      expect(doc).to match a_hash_including('default_use_license_machine_ssi' => 'by-nc-sa')
    end
  end
end
