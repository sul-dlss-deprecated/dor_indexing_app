# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentBuilder do
  subject(:indexer) { described_class.for(model: cocina_with_metadata) }

  let(:cocina_with_metadata) do
    Cocina::Models.with_metadata(cocina, 'unknown_lock', created: DateTime.parse('Wed, 01 Jan 2020 12:00:01 GMT'), modified: DateTime.parse('Thu, 04 Mar 2021 23:05:34 GMT'))
  end

  let(:druid) { 'druid:xx999xx9999' }
  # rubocop:disable Style/StringHashKeys
  let(:releasable) do
    instance_double(ReleasableIndexer, to_solr: { 'released_to_ssim' => %w[searchworks earthworks] })
  end
  let(:workflows) do
    instance_double(WorkflowsIndexer, to_solr: { 'wf_ssim' => ['accessionWF'] })
  end
  let(:admin_tags) do
    instance_double(AdministrativeTagIndexer, to_solr: { 'tag_ssim' => ['Test : Tag'] })
  end
  # rubocop:enable Style/StringHashKeys
  let(:admin_tags_client) do
    instance_double(Dor::Services::Client::AdministrativeTags, list: [])
  end
  let(:object_client) do
    instance_double(Dor::Services::Client::Object, administrative_tags: admin_tags_client)
  end

  before do
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    # rubocop:disable Style/StringHashKeys
    allow(WorkflowFields).to receive(:for).and_return({ 'milestones_ssim' => %w[foo bar] })
    # rubocop:enable Style/StringHashKeys
    allow(ReleasableIndexer).to receive(:new).and_return(releasable)
    allow(WorkflowsIndexer).to receive(:new).and_return(workflows)
    allow(AdministrativeTagIndexer).to receive(:new).and_return(admin_tags)
  end

  context 'when the model is an item' do
    let(:cocina) do
      build(:dro, id: druid).new(
        structural: {
          isMemberOf: collections
        }
      )
    end

    context 'without collections' do
      let(:collections) { [] }

      it { is_expected.to be_instance_of CompositeIndexer::Instance }
    end

    context 'with collections' do
      let(:object_client) do
        instance_double(Dor::Services::Client::Object, find: related, administrative_tags: admin_tags_client)
      end
      let(:related) { build(:collection) }
      let(:collections) { ['druid:bc999df2323'] }

      it { is_expected.to be_instance_of CompositeIndexer::Instance }
    end

    context "with collections that can't be resolved" do
      let(:collections) { ['druid:bc999df2323'] }

      before do
        allow(Dor::Services::Client).to receive(:object).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'logs to honeybadger' do
        allow(Honeybadger).to receive(:notify).and_return('16ae4ff7-9449-43af-9988-77772858878c')
        expect(indexer).to be_instance_of CompositeIndexer::Instance

        # Ensure that errors are stripped out of parent_collections
        expect(AdministrativeTagIndexer).to have_received(:new)
          .with(cocina: Cocina::Models::DROWithMetadata,
                id: String,
                administrative_tags: [],
                parent_collections: [])
        expect(Honeybadger).to have_received(:notify).with('Bad association found on druid:xx999xx9999. druid:bc999df2323 could not be found')
      end
    end
  end

  context 'when the model is an admin policy' do
    let(:cocina) { build(:admin_policy) }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is a collection' do
    let(:cocina) { build(:collection) }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is an agreement' do
    let(:cocina) { build(:dro, type: Cocina::Models::ObjectType.agreement) }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  describe '#to_solr' do
    subject(:solr_doc) { indexer.to_solr }

    let(:apo_id) { 'druid:bd999bd9999' }
    let(:apo) { build(:admin_policy, id: apo_id) }
    let(:apo_object_client) { instance_double(Dor::Services::Client::Object, find: apo) }

    before do
      allow(Dor::Services::Client).to receive(:object).with(apo_id).and_return(apo_object_client)
      allow(apo_object_client).to receive_message_chain(:administrative_tags, :list).and_return([])
    end

    context 'when the model is an item' do
      let(:cocina) do
        build(:dro, id: druid, admin_policy_id: apo_id).new(
          description: {
            title: [{ value: 'Test obj' }],
            purl: "https://purl.stanford.edu/#{druid.delete_prefix('druid:')}",
            subject: [{ type: 'topic', value: 'word' }],
            event: [
              {
                type: 'creation',
                date: [
                  {
                    value: '2021-01-01',
                    status: 'primary',
                    encoding: {
                      code: 'w3cdtf'
                    },
                    type: 'creation'
                  }
                ]
              },
              {
                type: 'publication',
                location: [
                  {
                    value: 'Moskva'
                  }
                ],
                contributor: [
                  {
                    name: [
                      {
                        value: 'Izdatelʹstvo "Vesʹ Mir"'
                      }
                    ],
                    type: 'organization',
                    role: [{ value: 'publisher' }]
                  }
                ]
              }
            ]
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
        build(:admin_policy, id: druid).new(
          administrative: {
            hasAdminPolicy: apo_id,
            hasAgreement: 'druid:bb033gt0615',
            accessTemplate: { view: 'world', download: 'world' }
          }
        )
      end

      it { is_expected.to include('milestones_ssim', 'wf_ssim', 'tag_ssim') }
    end

    context 'when the model is a hydrus apo' do
      let(:model) { Hydrus::AdminPolicyObject.new(pid: druid) }
      let(:cocina) do
        build(:admin_policy, id: druid).new(
          administrative: {
            hasAdminPolicy: apo_id,
            hasAgreement: 'druid:bb033gt0615',
            accessTemplate: { view: 'world', download: 'world' }
          }
        )
      end

      it { is_expected.to include('milestones_ssim', 'wf_ssim', 'tag_ssim') }
    end
  end
end
