# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbargoMetadataDatastreamIndexer do
  let(:xml) do
    <<~XML
      <?xml version="1.0"?>
      <embargoMetadata>
        <status>embargoed</status>
        <releaseDate>2011-10-12T15:47:52-07:00</releaseDate>
        <twentyPctVisibilityStatus>released</twentyPctVisibilityStatus>
        <twentyPctVisibilityReleaseDate>2016-10-12T15:47:52-07:00</twentyPctVisibilityReleaseDate>
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

    it 'has the fields used by argo' do
      expect(doc).to eq('embargo_release_dtsim' => ['2011-10-12T22:47:52Z'],
                        'embargo_status_ssim' => ['embargoed'],
                        'twenty_pct_status_ssim' => ['released'],
                        'twenty_pct_release_embargo_release_dtsim' => ['2016-10-12T22:47:52Z'])
    end
  end
end
