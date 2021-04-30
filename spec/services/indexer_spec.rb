# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Indexer do
  subject(:indexer) { described_class.for(model: cocina, metadata: metadata) }

  let(:metadata) { { 'Last-Modified' => 'Thu, 04 Mar 2021 23:05:34 GMT' } }
  let(:druid) { 'druid:xx999xx9999' }
  let(:releasable) do
    instance_double(ReleasableIndexer, to_solr: { 'released_to_ssim' => %w[searchworks earthworks] })
  end
  let(:workflows) do
    instance_double(WorkflowsIndexer, to_solr: { 'wf_ssim' => ['accessionWF'] })
  end
  let(:admin_tags) do
    instance_double(AdministrativeTagIndexer, to_solr: { 'tag_ssim' => ['Test : Tag'] })
  end

  before do
    allow(WorkflowFields).to receive(:for).and_return({ 'milestones_ssim' => %w[foo bar] })
    allow(ReleasableIndexer).to receive(:new).and_return(releasable)
    allow(WorkflowsIndexer).to receive(:new).and_return(workflows)
    allow(AdministrativeTagIndexer).to receive(:new).and_return(admin_tags)
  end

  context 'when the model is an item' do
    let(:cocina) do
      instance_double(Cocina::Models::DRO,
                      type: Cocina::Models::Vocab.object,
                      externalIdentifier: druid)
    end

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is an admin policy' do
    let(:cocina) do
      instance_double(Cocina::Models::AdminPolicy,
                      type: Cocina::Models::Vocab.admin_policy,
                      externalIdentifier: druid)
    end

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is a hydrus item' do
    # let(:model) { Hydrus::Item.new }
    let(:cocina) do
      instance_double(Cocina::Models::DRO,
                      type: Cocina::Models::Vocab.object,
                      externalIdentifier: druid)
    end

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is a hydrus apo' do
    # let(:model) { Hydrus::AdminPolicyObject.new(pid: druid) }
    let(:cocina) do
      instance_double(Cocina::Models::AdminPolicy,
                      type: Cocina::Models::Vocab.admin_policy,
                      externalIdentifier: druid)
    end

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is a collection' do
    # let(:model) { Dor::Collection.new }
    let(:cocina) do
      instance_double(Cocina::Models::Collection,
                      type: Cocina::Models::Vocab.collection,
                      externalIdentifier: druid)
    end

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is an agreement' do
    let(:cocina) do
      instance_double(Cocina::Models::DRO,
                      type: Cocina::Models::Vocab.agreement,
                      externalIdentifier: druid)
    end

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  describe '#to_solr' do
    subject(:solr_doc) { indexer.to_solr }

    let(:apo_id) { 'druid:bd999bd9999' }

    let(:apo) do
      Cocina::Models.build(
        'externalIdentifier' => apo_id,
        'type' => Cocina::Models::Vocab.admin_policy,
        'version' => 1,
        'label' => 'testing',
        'administrative' => {
          'hasAdminPolicy' => 'druid:xx000xx0000'
        },
        'description' => {
          'title' => [{ 'value' => 'APO title' }]
        }
      )
    end

    let(:apo_object_client) { instance_double(Dor::Services::Client::Object, find: apo) }

    before do
      allow(Dor::Services::Client).to receive(:object).with(apo_id).and_return(apo_object_client)
      allow(apo_object_client).to receive_message_chain(:administrative_tags, :list).and_return([])
    end

    context 'when the model is an item' do
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
            'subject' => [{ 'type' => 'topic', 'value' => 'word' }],
            'event' => [
              {
                'type' => 'creation',
                'date' => [
                  {
                    'value' => '2021-01-01',
                    'status' => 'primary',
                    'encoding' => {
                      'code' => 'w3cdtf'
                    },
                    'type' => 'creation'
                  }
                ]
              },
              {
                'type' => 'publication',
                'location' => [
                  {
                    'value' => 'Moskva'
                  }
                ],
                'contributor' => [
                  {
                    'name' => [
                      {
                        'value' => 'Izdatelʹstvo "Vesʹ Mir"'
                      }
                    ],
                    'type' => 'organization',
                    'role' => [{ 'value' => 'publisher' }]
                  }
                ]
              }
            ]
          },
          'structural' => {
            'contains' => [],
            'isMemberOf' => []
          },
          'identification' => {
            'catalogLinks' => [{ 'catalog' => 'symphony', 'catalogRecordId' => '1234' }]
          }
        )
      end

      it 'has required fields' do
        expect(solr_doc).to include('milestones_ssim', 'wf_ssim', 'tag_ssim')

        expect(solr_doc['originInfo_date_created_tesim']).to eq '2021-01-01'
        expect(solr_doc['originInfo_publisher_tesim']).to eq 'Izdatelʹstvo "Vesʹ Mir"'
        expect(solr_doc['originInfo_place_placeTerm_tesim']).to eq 'Moskva'
      end
    end

    context 'when the model is an admin policy' do
      let(:model) { Dor::AdminPolicyObject.new(pid: druid) }

      let(:cocina) do
        Cocina::Models.build(
          'externalIdentifier' => druid,
          'type' => Cocina::Models::Vocab.admin_policy,
          'version' => 1,
          'label' => 'testing',
          'administrative' => {
            'hasAdminPolicy' => apo_id,
            'defaultObjectRights' => '<rightsMetadata/>'
          },
          'description' => {
            'title' => [{ 'value' => 'Test obj' }]
          }
        )
      end

      it { is_expected.to include('milestones_ssim', 'wf_ssim', 'tag_ssim') }
    end

    context 'when the model is a hydrus apo' do
      let(:model) { Hydrus::AdminPolicyObject.new(pid: druid) }

      let(:cocina) do
        Cocina::Models.build(
          'externalIdentifier' => druid,
          'type' => Cocina::Models::Vocab.admin_policy,
          'version' => 1,
          'label' => 'testing',
          'administrative' => {
            'hasAdminPolicy' => apo_id,
            'defaultObjectRights' => '<rightsMetadata/>'
          },
          'description' => {
            'title' => [{ 'value' => 'Test obj' }]
          }
        )
      end

      it { is_expected.to include('milestones_ssim', 'wf_ssim', 'tag_ssim') }
    end
  end
end
