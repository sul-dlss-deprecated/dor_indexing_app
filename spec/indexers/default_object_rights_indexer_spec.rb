# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DefaultObjectRightsIndexer do
  let(:cocina) do
    Cocina::Models.build(
      {
        label: 'The APO',
        version: 1,
        type: Cocina::Models::ObjectType.admin_policy,
        externalIdentifier: 'druid:cb123cd4567',
        administrative: {
          hasAdminPolicy: 'druid:hv992ry2431',
          hasAgreement: 'druid:bb033gt0615',
          accessTemplate: {
            useAndReproductionStatement: 'Rights are owned by Stanford University Libraries.',
            copyright: 'Additional copyright info',
            view: 'location-based',
            download: 'location-based',
            location: 'spec'
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
      # rubocop:disable Style/StringHashKeys
      expect(doc).to match a_hash_including('use_statement_ssim' =>
        'Rights are owned by Stanford University Libraries.')
      expect(doc).to match a_hash_including('copyright_ssim' => 'Additional copyright info')
      expect(doc).to match a_hash_including('rights_descriptions_ssim' => 'dark')
      expect(doc).to match a_hash_including('default_rights_descriptions_ssim' => ['location: spec'])
      # rubocop:enable Style/StringHashKeys
    end
  end
end
