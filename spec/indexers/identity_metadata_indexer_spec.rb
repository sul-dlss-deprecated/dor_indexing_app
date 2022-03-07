# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentityMetadataIndexer do
  let(:cocina) do
    Cocina::Models.build({
      externalIdentifier: 'druid:rt923jk3421',
      type: type,
      version: 1,
      label: 'Squirrels of North America',
      description: {
        title: [{ value: 'Squirrels of North America' }],
        purl: 'https://purl.stanford.edu/rt923jk3421'
      },
      access: {},
      administrative: {
        hasAdminPolicy: 'druid:bd999bd9999'
      },
      identification: identification
    }.with_indifferent_access)
  end

  let(:indexer) do
    described_class.new(cocina: cocina)
  end

  describe '#to_solr' do
    subject(:doc) { indexer.to_solr }

    context 'with an item' do
      let(:type) { Cocina::Models::Vocab.book }
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

    context 'with an agreement' do
      let(:type) { Cocina::Models::Vocab.agreement }
      let(:identification) { {} }

      it 'has the fields used by argo' do
        expect(doc).to include(
          'barcode_id_ssim' => [],
          'catkey_id_ssim' => [],
          'dor_id_tesim' => [],
          'identifier_ssim' => [],
          'identifier_tesim' => [],
          'objectType_ssim' => ['agreement'],
          'source_id_ssim' => []
        )
      end
    end

    context 'with a collection' do
      let(:type) { Cocina::Models::Vocab.collection }
      let(:identification) do
        {
          sourceId: 'google:STANFORD_342837261527',
          catalogLinks: [
            {
              catalog: 'symphony',
              catalogRecordId: '129483625'
            }
          ]
        }
      end

      it 'has the fields used by argo' do
        expect(doc).to include(
          'barcode_id_ssim' => [],
          'catkey_id_ssim' => ['129483625'],
          'dor_id_tesim' => %w[STANFORD_342837261527 129483625],
          'identifier_ssim' => ['google:STANFORD_342837261527', 'catkey:129483625'],
          'identifier_tesim' => ['google:STANFORD_342837261527', 'catkey:129483625'],
          'objectType_ssim' => ['collection'],
          'source_id_ssim' => ['google:STANFORD_342837261527']
        )
      end
    end
  end
end
