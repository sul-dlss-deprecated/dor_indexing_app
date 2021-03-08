# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbargoMetadataDatastreamIndexer do
  let(:xml) do
    <<~XML
      <?xml version="1.0"?>
      <embargoMetadata>
        <status>embargoed</status>
        <releaseDate>2011-10-12T15:47:52-07:00</releaseDate>
        <releaseAccess>
          <access type="discover">
            <machine>
              <world />
            </machine>
          </access>
          <access type="read">
            <machine>
              <world />
            </machine>
          </access>
        </releaseAccess>
      </embargoMetadata>
    XML
  end

  let(:obj) { Dor::Item.new }
  let(:cocina) { Success(instance_double(Cocina::Models::DRO)) }

  let(:indexer) do
    described_class.new(resource: obj, cocina: cocina)
  end

  before do
    obj.embargoMetadata.content = xml
  end

  describe '#to_solr' do
    subject(:doc) { indexer.to_solr }

    it 'has the fields used by dor-services-app' do
      expect(doc).to eq('embargo_release_dtsim' => ['2011-10-12T22:47:52Z'],
                        'embargo_status_ssim' => ['embargoed'])
    end
  end
end
