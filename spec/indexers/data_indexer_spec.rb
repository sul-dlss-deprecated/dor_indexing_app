# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataIndexer do
  let(:obj) do
    Dor::AdminPolicyObject.new(pid: 'druid:999')
  end

  let(:indexer) do
    described_class.new(resource: obj, cocina: cocina)
  end
  let(:cocina) { instance_double(Cocina::Models::DRO) }

  describe '#to_solr' do
    let(:indexer) do
      CompositeIndexer.new(
        described_class
      ).new(resource: obj, cocina: cocina)
    end
    let(:doc) { indexer.to_solr }

    it 'makes a solr doc' do
      expect(doc).to match a_hash_including(id: 'druid:999')
    end
  end
end
