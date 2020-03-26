# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Indexer do
  subject(:indexer) { described_class.for(model) }

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

    it { is_expected.to be_instance_of CompositeIndexer::Instance }

    describe '#to_solr' do
      subject { indexer.to_solr }

      it { is_expected.to include('milestones_ssim', 'released_to_ssim', 'wf_ssim', 'tag_ssim') }
    end
  end

  context 'when the model is an admin policy' do
    let(:model) { Dor::AdminPolicyObject.new(pid: 'druid:xx999xx9999') }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }

    describe '#to_solr' do
      subject { indexer.to_solr }

      it { is_expected.to include('milestones_ssim', 'wf_ssim', 'tag_ssim') }
    end
  end

  context 'when the model is a hydrus item' do
    let(:model) { Hydrus::Item.new }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is a hydrus apo' do
    let(:model) { Hydrus::AdminPolicyObject.new(pid: 'druid:xx999xx9999') }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }

    describe '#to_solr' do
      subject { indexer.to_solr }

      it { is_expected.to include('milestones_ssim', 'wf_ssim', 'tag_ssim') }
    end
  end

  context 'when the model is a collection' do
    let(:model) { Dor::Collection.new }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is an agreement' do
    let(:model) { Dor::Agreement.new }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end
end
