# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentifiableIndexer do
  let(:druid) { 'druid:rt923jk3422' }
  let(:apo_id) { 'druid:bd999bd9999' }
  let(:cocina) do
    Cocina::Models.build(
      {
        externalIdentifier: druid,
        type: Cocina::Models::ObjectType.image,
        version: 1,
        label: 'testing',
        access: {},
        administrative: {
          hasAdminPolicy: apo_id
        },
        description: {
          title: [{ value: 'Test obj' }],
          subject: [{ type: 'topic', value: 'word' }],
          purl: 'https://purl.stanford.edu/rt923jk3422'
        },
        structural: {
          contains: [],
          isMemberOf: []
        },
        identification: identification
      }
    )
  end
  let(:identification) do
    {
      catalogLinks: [{ catalog: 'symphony', catalogRecordId: '1234' }],
      sourceId: 'sul:1234'
    }
  end

  let(:indexer) do
    described_class.new(cocina: cocina)
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

    let(:related) do
      Cocina::Models.build(
        {
          externalIdentifier: apo_id,
          type: Cocina::Models::ObjectType.admin_policy,
          version: 1,
          label: 'testing',
          administrative: {
            hasAdminPolicy: apo_id,
            hasAgreement: 'druid:bb033gt0615',
            accessTemplate: { view: 'world', download: 'world' }
          },
          description: {
            title: [{ value: 'Test object' }],
            purl: 'https://purl.stanford.edu/rt923jk3422'
          }
        }
      )
    end
    let(:object_client) do
      instance_double(Dor::Services::Client::Object, find: related)
    end

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
      let(:related) do
        Cocina::Models.build(
          {
            externalIdentifier: mock_rel_druid,
            type: Cocina::Models::ObjectType.collection,
            version: 1,
            label: 'testing',
            administrative: {
              hasAdminPolicy: apo_id
            },
            access: {},
            description: {
              title: [{ value: 'Test object' }],
              purl: 'https://purl.stanford.edu/rt923jk3422'
            },
            identification: { sourceId: 'sul:1234' }
          }
        )
      end

      it 'generates apo title fields' do
        expect(doc[Solrizer.solr_name('apo_title', :symbol)].first).to eq 'Test object'
        expect(doc[Solrizer.solr_name('nonhydrus_apo_title', :symbol)].first).to eq 'Test object'
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
      let(:cocina) do
        Cocina::Models.build(
          {
            externalIdentifier: druid,
            type: Cocina::Models::ObjectType.image,
            version: 1,
            label: 'testing',
            access: {},
            administrative: {
              hasAdminPolicy: apo_id
            },
            description: {
              title: [{ value: 'Test obj' }],
              subject: [{ type: 'topic', value: 'word' }],
              purl: 'https://purl.stanford.edu/rt923jk3422'
            },
            structural: {},
            identification: { sourceId: 'sul:1234' }
          }
        )
      end

      it 'indexes metadata source' do
        # rubocop:disable Style/StringHashKeys
        expect(doc).to match a_hash_including('metadata_source_ssi' => 'DOR')
        # rubocop:enable Style/StringHashKeys
      end
    end
  end
end
