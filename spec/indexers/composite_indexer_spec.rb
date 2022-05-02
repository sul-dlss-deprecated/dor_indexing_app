# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompositeIndexer do
  let(:druid) { 'druid:mx123ms3333' }
  let(:apo_id) { 'druid:gf999hb9999' }
  let(:apo) { build(:admin_policy, id: apo_id, title: 'test admin policy') }
  let(:indexer) do
    described_class.new(
      DescriptiveMetadataIndexer,
      IdentifiableIndexer
    )
  end

  let(:cocina_item) do
    build(:dro, id: druid).new(
      description: {
        title: [{ value: 'Test item' }],
        subject: [{ type: 'topic', value: 'word' }],
        purl: 'https://purl.stanford.edu/mx123ms3333'
      }
    )
  end
  let(:object_client) { instance_double(Dor::Services::Client::Object, find: apo) }

  before do
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(object_client).to receive_message_chain(:administrative_tags, :list).and_return([])
  end

  describe 'to_solr' do
    let(:status) do
      instance_double(Dor::Workflow::Client::Status, milestones: {}, info: {}, display: 'bad')
    end
    let(:workflow_client) { instance_double(Dor::Workflow::Client, status: status) }
    let(:doc) { indexer.new(id: druid, cocina: cocina_item).to_solr }

    before do
      allow(Dor::Workflow::Client).to receive(:new).and_return(workflow_client)
    end

    it 'calls each of the provided indexers and combines the results' do
      # rubocop:disable Style/StringHashKeys
      expect(doc).to eq(
        'metadata_format_ssim' => 'mods',
        'sw_display_title_tesim' => 'Test item',
        'nonhydrus_apo_title_ssim' => ['test admin policy'],
        'apo_title_ssim' => ['test admin policy'],
        'metadata_source_ssi' => 'DOR',
        'objectId_tesim' => ['druid:mx123ms3333', 'mx123ms3333'],
        'topic_ssim' => ['word'],
        'topic_tesim' => ['word']
      )
      # rubocop:enable Style/StringHashKeys
    end
  end
end
