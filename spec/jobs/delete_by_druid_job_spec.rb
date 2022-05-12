# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteByDruidJob do
  let(:message) { { druid: druid, deleted_at: Time.zone.now }.to_json }
  let(:druid) { 'druid:bc123df4567' }

  before do
    allow(Indexer).to receive(:delete)
  end

  it 'updates the druid' do
    described_class.new.work(message)
    expect(Indexer).to have_received(:delete).with(solr: RSolr::Client, identifier: druid)
  end
end
