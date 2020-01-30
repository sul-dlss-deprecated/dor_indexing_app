# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Indexer do
  subject(:indexer) { described_class.for(model) }

  context 'when the model is an item' do
    let(:model) { Dor::Item.new }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
  end

  context 'when the model is a hydrus item' do
    let(:model) { Hydrus::Item.new }

    it { is_expected.to be_instance_of CompositeIndexer::Instance }
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
