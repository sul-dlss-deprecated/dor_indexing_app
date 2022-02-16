# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteByDruidJob do
  let(:message) { { druid: druid, deleted_at: Time.zone.now }.to_json }
  let(:druid) { 'druid:bc123df4567' }
  let(:mock_solr) { instance_double(RSolr::Client, delete_by_id: true, commit: true) }

  before do
    allow(RSolr).to receive(:connect).and_return(mock_solr)
  end

  it 'updates the druid' do
    described_class.new.work(message)
    expect(mock_solr).to have_received(:delete_by_id).with(druid, commitWithin: 1000).once
    expect(mock_solr).to have_received(:commit).once
  end
end
