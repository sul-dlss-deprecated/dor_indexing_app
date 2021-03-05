# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompositeIndexer do
  let(:model) { Dor::Abstract }
  let(:druid) { 'druid:mx123ms3333' }
  let(:mods) do
    double('mods', sw_title_display: 'foo', sw_genre: ['test genre'],
                   main_author_w_date: '1999',
                   sw_sort_author: 'baz',
                   sw_language_facet: 'en',
                   format_main: 'foofmt',
                   topic_facet: 'topicbar',
                   era_facet: ['17th century', '18th century'],
                   geographic_facet: %w[Europe Europe],
                   term_values: 'huh?',
                   pub_year_sort_str: '1600',
                   pub_year_int: 1600,
                   pub_year_display_str: '1600')
  end
  let(:obj) do
    instance_double(Dor::Item,
                    pid: druid,
                    stanford_mods: mods,
                    label: 'obj label',
                    identityMetadata: identity_metadata,
                    versionMetadata: version_metadata,
                    current_version: '7',
                    modified_date: '1999-12-30',
                    admin_policy_object_id: apo_id,
                    collections: [])
  end
  let(:apo_id) { 'druid:gf999hb9999' }
  let(:apo) do
    instance_double(Cocina::Models::AdminPolicy, label: 'APO title')
  end
  let(:identity_metadata) do
    instance_double(Dor::IdentityMetadataDS, otherId: 'foo')
  end
  let(:version_metadata) do
    instance_double(Dor::VersionMetadataDS, tag_for_version: 'tag7', description_for_version: 'desc7', current_version_id: '7')
  end

  let(:indexer) do
    described_class.new(
      DescribableIndexer,
      IdentifiableIndexer
    )
  end

  let(:cocina) do
    Cocina::Models.build(
      'externalIdentifier' => druid,
      'type' => Cocina::Models::Vocab.image,
      'version' => 1,
      'label' => 'testing',
      'access' => {},
      'administrative' => {
        'hasAdminPolicy' => apo_id
      },
      'description' => {
        'title' => [{ 'value' => 'Test obj' }],
        'subject' => [{ 'type' => 'topic', 'value' => 'word' }]
      },
      'structural' => {
        'contains' => []
      },
      'identification' => {
        'catalogLinks' => [{ 'catalog' => 'symphony', 'catalogRecordId' => '1234' }]
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
    let(:doc) { indexer.new(id: 'druid:ab123cd4567', resource: obj, cocina: cocina).to_solr }

    before do
      allow(Dor::Workflow::Client).to receive(:new).and_return(workflow_client)
    end

    it 'searchworks date-fu: temporal periods and pub_dates' do
      expect(doc).to match a_hash_including(
        'sw_subject_temporal_ssim' => a_collection_containing_exactly('18th century', '17th century'),
        'sw_pub_date_sort_ssi' => '1600',
        'sw_pub_date_facet_ssi' => '1600'
      )
    end

    it 'subject geographic fields' do
      expect(doc).to match a_hash_including(
        'sw_subject_geographic_ssim' => %w[Europe Europe]
      )
    end

    it 'genre fields' do
      genre_list = obj.stanford_mods.sw_genre
      expect(doc).to match a_hash_including(
        'sw_genre_ssim' => genre_list
      )
    end
  end
end
