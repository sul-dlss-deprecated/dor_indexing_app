# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentityMetadataDatastreamIndexer do
  let(:obj) { Dor::Item.new(pid: 'druid:rt923jk3421') }

  let(:cocina) do
    Cocina::Models.build({
      externalIdentifier: 'druid:rt923jk3421',
      type: Cocina::Models::Vocab.book,
      version: 1,
      label: 'Squirrels of North America',
      access: {
        access: 'world'
      },
      administrative: {
        hasAdminPolicy: 'druid:bd999bd9999'
      },
      identification: identification
    }.with_indifferent_access)
  end

  let(:indexer) do
    described_class.new(resource: obj, cocina: cocina)
  end

  describe '#to_solr' do
    subject(:doc) { indexer.to_solr }

    context 'when all fields are present' do
      let(:identification) do
        {
          sourceId: 'google:STANFORD_342837261527',
          catalogLinks: [
            {
              catalog: 'symphony',
              catalogRecordId: '129483625'
            }
          ],
          barcode: '36105049267078'
        }
      end

      it 'has the fields used by argo' do
        expect(doc).to include(
          'barcode_id_ssim' => ['36105049267078'],
          'catkey_id_ssim' => ['129483625'],
          'dor_id_tesim' => %w[STANFORD_342837261527 36105049267078 129483625],
          'identifier_ssim' => ['google:STANFORD_342837261527', 'barcode:36105049267078',
                                'catkey:129483625'],
          'identifier_tesim' => ['google:STANFORD_342837261527', 'barcode:36105049267078',
                                 'catkey:129483625'],
          'objectType_ssim' => ['item'],
          'source_id_ssim' => ['google:STANFORD_342837261527']
        )
      end
    end
  end
end
