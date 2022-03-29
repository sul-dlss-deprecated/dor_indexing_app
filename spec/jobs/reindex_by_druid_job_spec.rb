# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReindexByDruidJob do
  let(:message) { { druid: druid }.to_json }
  let(:druid) { 'druid:bc123df4567' }

  let(:indexer) { instance_double(Indexer, load_and_index: true) }

  before do
    allow(Indexer).to receive(:new).and_return(indexer)
  end

  context 'when object is found' do
    let(:result) { Success(double) }

    before do
      allow(indexer).to receive(:fetch_model_with_metadata).and_return(result)
    end

    it 'updates the druid' do
      described_class.new.work(message)
      expect(indexer).to have_received(:load_and_index)
    end
  end

  context 'when object is not found' do
    before do
      allow(indexer).to receive(:load_and_index).and_raise(Dor::Services::Client::NotFoundResponse)
      allow(Honeybadger).to receive(:notify)
    end

    it 'does not update the druid' do
      described_class.new.work(message)
      expect(Honeybadger).to have_received(:notify)
    end
  end
end
