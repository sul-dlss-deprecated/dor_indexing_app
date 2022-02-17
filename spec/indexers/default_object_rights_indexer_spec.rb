# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DefaultObjectRightsIndexer do
  let(:cocina) do
    Cocina::Models.build(
      {
        'label' => 'The APO',
        'version' => 1,
        'type' => Cocina::Models::Vocab.admin_policy,
        'externalIdentifier' => 'druid:cb123cd4567',
        'administrative' => {
          hasAdminPolicy: 'druid:hv992ry2431',
          hasAgreement: 'druid:bb033gt0615',
          defaultAccess: {
            useAndReproductionStatement: 'Rights are owned by Stanford University Libraries.',
            copyright: 'Additional copyright info',
            access: 'location-based',
            download: 'location-based',
            readLocation: 'spec'
          }
        }
      }
    )
  end

  describe '#to_solr' do
    let(:indexer) do
      CompositeIndexer.new(
        described_class
      ).new(id: 'druid:ab123cd4567', cocina: cocina)
    end
    let(:doc) { indexer.to_solr }

    it 'makes a solr doc' do
      expect(doc).to match a_hash_including('use_statement_ssim' =>
        'Rights are owned by Stanford University Libraries.')
      expect(doc).to match a_hash_including('copyright_ssim' => 'Additional copyright info')
      expect(doc).to match a_hash_including('rights_descriptions_ssim' => 'Dark')
      expect(doc).to match a_hash_including('default_rights_descriptions_ssim' => ['location: spec'])
    end
  end
end
