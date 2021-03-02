# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Indexer do
  subject(:indexer) { described_class.for(model, cocina: Success(cocina)) }

  let(:processable) do
    instance_double(ProcessableIndexer, to_solr: { 'milestones_ssim' => %w[foo bar] })
  end
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
    allow(ProcessableIndexer).to receive(:new).and_return(processable)
    allow(ReleasableIndexer).to receive(:new).and_return(releasable)
    allow(WorkflowsIndexer).to receive(:new).and_return(workflows)
    allow(AdministrativeTagIndexer).to receive(:new).and_return(admin_tags)
  end

  context 'when the model is an item' do
    let(:model) { Dor::Item.new(pid: 'druid:xx999xx9999') }
    let(:cocina) { instance_double(Cocina::Models::DRO) }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is an admin policy' do
    let(:model) { Dor::AdminPolicyObject.new(pid: 'druid:xx999xx9999') }
    let(:cocina) { instance_double(Cocina::Models::AdminPolicy) }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is a hydrus item' do
    let(:model) { Hydrus::Item.new }
    let(:cocina) { instance_double(Cocina::Models::DRO) }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is a hydrus apo' do
    let(:model) { Hydrus::AdminPolicyObject.new(pid: 'druid:xx999xx9999') }
    let(:cocina) { instance_double(Cocina::Models::AdminPolicy) }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is a collection' do
    let(:model) { Dor::Collection.new }
    let(:cocina) { instance_double(Cocina::Models::Collection) }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is an agreement' do
    let(:model) { Dor::Agreement.new }
    let(:cocina) { instance_double(Cocina::Models::DRO) }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  describe '#to_solr' do
    subject(:solr_doc) { indexer.to_solr }

    let(:object_client) { instance_double(Dor::Services::Client::Object) }
    let(:apo_id) { 'druid:9999' }
    let(:apo) do
      instance_double(Dor::AdminPolicyObject, full_title: 'APO title', pid: apo_id)
    end

    before do
      allow(model).to receive(:admin_policy_object_id).and_return(apo_id)
      allow(model).to receive(:collection_ids).and_return([])

      allow(Dor).to receive(:find).and_return(apo)
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      allow(object_client).to receive_message_chain(:administrative_tags, :list).and_return([])
    end

    context 'when the model is an item' do
      before do
        model.contentMetadata.contentType = ['image']
      end

      context 'when cocina fetch is successful' do
        let(:model) { Dor::Item.new(pid: 'druid:xx999xx9999') }
        let(:cocina) { instance_double(Cocina::Models::DRO, structural: structural) }
        let(:structural) { instance_double(Cocina::Models::DROStructural, contains: []) }

        it { is_expected.to include('milestones_ssim', 'released_to_ssim', 'wf_ssim', 'tag_ssim') }
      end

      context 'when cocina fails to fetch' do
        let(:indexer) { described_class.for(model, cocina: Failure(:conversion_error)) }
        let(:model) { Dor::Item.new(pid: 'druid:xx999xx9999') }

        it { is_expected.to include('milestones_ssim', 'released_to_ssim', 'wf_ssim', 'tag_ssim', 'obj_label_tesim', :id) }
      end
    end

    context 'when the model is an admin policy' do
      let(:model) { Dor::AdminPolicyObject.new(pid: 'druid:xx999xx9999') }
      let(:cocina) { instance_double(Cocina::Models::AdminPolicy) }

      it { is_expected.to include('milestones_ssim', 'wf_ssim', 'tag_ssim') }
    end

    context 'when the model is a hydrus apo' do
      let(:model) { Hydrus::AdminPolicyObject.new(pid: 'druid:xx999xx9999') }
      let(:cocina) { instance_double(Cocina::Models::AdminPolicy) }

      it { is_expected.to include('milestones_ssim', 'wf_ssim', 'tag_ssim') }
    end
  end
end
