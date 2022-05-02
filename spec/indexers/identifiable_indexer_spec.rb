# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentifiableIndexer do
  let(:druid) { 'druid:rt923jk3422' }
  let(:apo_id) { 'druid:bd999bd9999' }
  let(:cocina_item) do
    build(:dro, id: druid, admin_policy_id: apo_id).new(
      identification: identification
    )
  end
  let(:identification) do
    {
      catalogLinks: [{ catalog: 'symphony', catalogRecordId: '1234', refresh: true }],
      sourceId: 'sul:1234'
    }
  end

  let(:indexer) do
    described_class.new(cocina: cocina_item)
  end

  before do
    described_class.reset_cache!
  end

  describe '#identity_metadata_source' do
    it 'indexes metadata source' do
      expect(indexer.identity_metadata_source).to eq 'Symphony'
    end
  end

  describe '#to_solr' do
    let(:doc) { indexer.to_solr }
    let(:mock_rel_druid) { 'druid:qf999gg9999' }
    let(:related) { build(:admin_policy, id: apo_id) }
    let(:object_client) { instance_double(Dor::Services::Client::Object, find: related) }

    before do
      allow(object_client).to receive_message_chain(:administrative_tags, :list).and_return([])
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    context 'when APO is not found' do
      before do
        allow(Dor::Services::Client).to receive(:object).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'generates apo title fields' do
        expect(doc[Solrizer.solr_name('apo_title', :symbol)].first).to eq apo_id
        expect(doc[Solrizer.solr_name('nonhydrus_apo_title', :symbol)].first).to eq apo_id
      end
    end

    context 'when APO is found' do
      let(:related) { build(:collection, id: mock_rel_druid, admin_policy_id: apo_id, title: 'collection title') }

      it 'generates apo title fields' do
        expect(doc[Solrizer.solr_name('apo_title', :symbol)].first).to eq 'collection title'
        expect(doc[Solrizer.solr_name('nonhydrus_apo_title', :symbol)].first).to eq 'collection title'
      end

      it 'indexes metadata source' do
        # rubocop:disable Style/StringHashKeys
        expect(doc).to match a_hash_including('metadata_source_ssi' => 'Symphony')
        # rubocop:enable Style/StringHashKeys
      end
    end

    context 'without catalogLinks' do
      let(:identification) { { sourceId: 'sul:1234' } }

      it 'indexes metadata source' do
        # rubocop:disable Style/StringHashKeys
        expect(doc).to match a_hash_including('metadata_source_ssi' => 'DOR')
        # rubocop:enable Style/StringHashKeys
      end
    end

    context 'with no identification sub-schema' do
      let(:cocina_item) { build(:dro, id: druid, admin_policy_id: apo_id) }

      it 'indexes metadata source' do
        # rubocop:disable Style/StringHashKeys
        expect(doc).to match a_hash_including('metadata_source_ssi' => 'DOR')
        # rubocop:enable Style/StringHashKeys
      end
    end
  end
end
