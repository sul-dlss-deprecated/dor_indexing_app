# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DefaultObjectRightsIndexer do
  let(:cocina) { instance_double(Cocina::Models::AdminPolicy, administrative: administrative) }
  let(:administrative) { instance_double(Cocina::Models::AdminPolicyAdministrative, defaultObjectRights: xml) }
  let(:xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>

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
            <human type="useAndReproduction">Rights are owned by Stanford University Libraries.</human>
         </use>
         <copyright>
            <human>Additional copyright info</human>
         </copyright>
      </rightsMetadata>
    XML
  end

  describe '#to_solr' do
    let(:indexer) do
      CompositeIndexer.new(
        described_class
      ).new(id: 'druid:ab123cd4567', resource: instance_double(Dor::AdminPolicyObject), cocina: cocina)
    end
    let(:doc) { indexer.to_solr }

    it 'makes a solr doc' do
      expect(doc).to match a_hash_including('use_statement_ssim' =>
        ['Rights are owned by Stanford University Libraries.'])
      expect(doc).to match a_hash_including('copyright_ssim' => ['Additional copyright info'])
    end
  end
end
