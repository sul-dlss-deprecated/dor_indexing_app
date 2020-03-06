# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RightsMetadataDatastreamIndexer do
  let(:xml) do
    <<~XML
      <?xml version="1.0"?>
      <rightsMetadata>
        <access type="discover">
          <machine>
            <world/>
          </machine>
        </access>
        <access type="read">
          <machine>
            <world/>
          </machine>
        </access>
        <use>
          <human type="useAndReproduction">Official WTO documents are free for public use.</human>
          <human type="creativeCommons"/>
          <machine type="creativeCommons"/>
        </use>
        <copyright>
          <human>Copyright &#xA9; World Trade Organization</human>
        </copyright>
      </rightsMetadata>
    XML
  end

  let(:obj) { Dor::Item.new(pid: 'druid:rt923jk342') }

  let(:indexer) do
    described_class.new(resource: obj)
  end

  before do
    obj.rightsMetadata.content = xml
  end

  describe '#to_solr' do
    subject(:doc) { indexer.to_solr }

    it 'has the fields used by argo' do
      expect(doc).to include(
        'copyright_ssim' => ['Copyright © World Trade Organization'],
        'use_statement_ssim' => ['Official WTO documents are free for public use.'],
        'rights_descriptions_ssim' => ['world']
      )
    end
  end
end
