# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Indexer do
  subject(:indexer) { described_class.for(fedora: fedora, cocina: cocina) }

  let(:cocina) { instance_double(Cocina::Models::DRO) }

  context 'when the model is an item' do
    let(:fedora) { Dor::Item.new(pid: 'druid:xx999xx9999') }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }

    describe '#to_solr' do
      subject { indexer.to_solr }

      let(:processable) do
        instance_double(ProcessableIndexer, to_solr: { 'milestones_ssim' => %w[foo bar] })
      end
      let(:releasable) do
        instance_double(ReleasableIndexer, to_solr: { 'released_to_ssim' => %w[searchworks earthworks] })
      end
      let(:workflows) do
        instance_double(WorkflowsIndexer, to_solr: { 'wf_ssim' => ['accessionWF'] })
      end

      before do
        allow(ProcessableIndexer).to receive(:new).and_return(processable)
        allow(ReleasableIndexer).to receive(:new).and_return(releasable)
        allow(WorkflowsIndexer).to receive(:new).and_return(workflows)
      end

      it { is_expected.to include('milestones_ssim', 'released_to_ssim', 'wf_ssim') }
    end
  end

  context 'when the model is an admin policy' do
    let(:fedora) { Dor::AdminPolicyObject.new(pid: 'druid:xx999xx9999') }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }

    describe '#to_solr' do
      subject { indexer.to_solr }

      let(:processable) do
        instance_double(ProcessableIndexer, to_solr: { 'milestones_ssim' => %w[foo bar] })
      end
      let(:workflows) do
        instance_double(WorkflowsIndexer, to_solr: { 'wf_ssim' => ['accessionWF'] })
      end

      before do
        allow(ProcessableIndexer).to receive(:new).and_return(processable)
        allow(WorkflowsIndexer).to receive(:new).and_return(workflows)
      end

      it { is_expected.to include('milestones_ssim', 'wf_ssim') }
    end
  end

  context 'when the model is a hydrus item' do
    let(:fedora) { Hydrus::Item.new }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is a hydrus apo' do
    let(:fedora) { Hydrus::AdminPolicyObject.new(pid: 'druid:xx999xx9999') }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }

    describe '#to_solr' do
      subject { indexer.to_solr }

      let(:processable) do
        instance_double(ProcessableIndexer, to_solr: { 'milestones_ssim' => %w[foo bar] })
      end
      let(:workflows) do
        instance_double(WorkflowsIndexer, to_solr: { 'wf_ssim' => ['accessionWF'] })
      end

      before do
        allow(ProcessableIndexer).to receive(:new).and_return(processable)
        allow(WorkflowsIndexer).to receive(:new).and_return(workflows)
      end

      it { is_expected.to include('milestones_ssim', 'wf_ssim') }
    end
  end

  context 'when the model is a collection' do
    let(:fedora) { Dor::Collection.new }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is an agreement' do
    let(:fedora) { Dor::Agreement.new }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end
end
