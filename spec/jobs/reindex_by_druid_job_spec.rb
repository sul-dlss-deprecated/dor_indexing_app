# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReindexByDruidJob do
  let(:message) { { druid: druid }.to_json }
  let(:druid) { 'druid:bc123df4567' }
  let(:result) { Success(double) }
  let(:indexer) { instance_double(Indexer, reindex_pid: true, fetch_model_with_metadata: result) }

  before do
    allow(Indexer).to receive(:new).and_return(indexer)
  end

  it 'updates the druid' do
    described_class.new.work(message)
    expect(indexer).to have_received(:reindex_pid)
      .with(add_attributes: { commitWithin: 1000 }, cocina_with_metadata: result)
  end
end
