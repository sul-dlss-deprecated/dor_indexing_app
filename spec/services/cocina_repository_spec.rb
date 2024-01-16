# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaRepository do
  let(:druid) { 'druid:bc123df4567' }

  describe '.find' do
    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    context 'when object is found' do
      let(:cocina_object) { instance_double(Cocina::Models::DROWithMetadata) }
      let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object) }

      it 'returns the object' do
        expect(described_class.new.find(druid)).to eq(cocina_object)
        expect(Dor::Services::Client).to have_received(:object).with(druid)
        expect(object_client).to have_received(:find)
      end
    end

    context 'when object is not found' do
      let(:object_client) { instance_double(Dor::Services::Client::Object) }

      before do
        allow(object_client).to receive(:find).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'raises' do
        expect { described_class.new.find(druid) }.to raise_error DorIndexing::CocinaRepository::RepositoryError
      end
    end
  end

  describe '.administrative_tags' do
    let(:object_client) { instance_double(Dor::Services::Client::Object, administrative_tags: tags_client) }
    let(:tags) { %w[wu tang] }

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    context 'when object is found' do
      let(:tags_client) { instance_double(Dor::Services::Client::AdministrativeTags, list: tags) }

      it 'returns the tags' do
        expect(described_class.new.administrative_tags(druid)).to eq(tags)
        expect(Dor::Services::Client).to have_received(:object).with(druid)
        expect(object_client).to have_received(:administrative_tags)
        expect(tags_client).to have_received(:list)
      end
    end

    context 'when object is not found' do
      let(:tags_client) { instance_double(Dor::Services::Client::AdministrativeTags) }

      before do
        allow(tags_client).to receive(:list).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'raises' do
        expect { described_class.new.administrative_tags(druid) }.to raise_error DorIndexing::CocinaRepository::RepositoryError
      end
    end
  end
end
