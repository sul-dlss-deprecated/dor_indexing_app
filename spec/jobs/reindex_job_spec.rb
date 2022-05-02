# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReindexJob do
  let(:message) { { model: model, created_at: 'Wed, 01 Jan 2021 12:58:00 GMT', modified_at: 'Wed, 03 Mar 2021 18:58:00 GMT' }.to_json }
  let(:model) { build(:dro) }
  let(:result) { Success(double) }
  let(:indexer) { instance_double(Indexer, reindex: true) }

  before do
    allow(Indexer).to receive(:new).and_return(indexer)
  end

  it 'updates the index' do
    described_class.new.work(message)
    expect(indexer).to have_received(:reindex)
      .with(add_attributes: { commitWithin: 1000 }, cocina_with_metadata: Success(Cocina::Models::DROWithMetadata))
  end
end
