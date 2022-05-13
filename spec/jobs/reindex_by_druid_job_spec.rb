# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReindexByDruidJob do
  let(:message) { { druid: druid }.to_json }
  let(:druid) { 'druid:bc123df4567' }

  context 'when object is found' do
    before do
      allow(Indexer).to receive(:load_and_index)
    end

    it 'updates the druid' do
      described_class.new.work(message)
      expect(Indexer).to have_received(:load_and_index).with(solr: RSolr::Client, identifier: druid)
    end
  end

  context 'when object is not found' do
    before do
      allow(Indexer).to receive(:load_and_index).and_raise(Dor::Services::Client::NotFoundResponse)
      allow(Honeybadger).to receive(:notify)
    end

    it 'does not update the druid' do
      described_class.new.work(message)
      expect(Honeybadger).to have_received(:notify)
    end
  end
end
