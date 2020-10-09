# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataQualityIndexer do
  let(:obj) { Dor::Item.new(pid: 'druid:rt923jk342') }
  let(:cocina) { Success(instance_double(Cocina::Models::DRO)) }

  let(:indexer) do
    described_class.new(resource: obj, cocina: cocina)
  end
  let(:xml) do
    <<~XML
      <identityMetadata>
        <objectId>druid:rt923jk342</objectId>
        <objectType>item</objectType>
        <objectLabel>google download barcode 36105049267078</objectLabel>
        <objectCreator>DOR</objectCreator>
        <citationTitle>Squirrels of North America</citationTitle>
        <citationCreator>Eder, Tamara, 1974-</citationCreator>
        <sourceId source="google">STANFORD_342837261527</sourceId>
        <otherId name="barcode">36105049267078</otherId>
        <otherId name="catkey">129483625</otherId>
        <otherId name="uuid">7f3da130-7b02-11de-8a39-0800200c9a66</otherId>
        <tag>Google Books : Phase 1</tag>
        <tag>Google Books : Scan source STANFORD</tag>
        <tag>Project : Beautiful Books</tag>
        <tag>Registered By : blalbrit</tag>
        <tag>DPG : Beautiful Books : Octavo : newpri</tag>
        <tag>Remediated By : 4.15.4</tag>
        <release displayType="image" release="true" to="Searchworks" what="self" when="2015-07-27T21:44:26Z" who="lauraw15">true</release>
        <release displayType="image" release="true" to="Some_special_place" what="self" when="2015-08-31T23:59:59" who="atz">true</release>
      </identityMetadata>
    XML
  end

  before do
    obj.identityMetadata.content = xml
  end

  describe '#to_solr' do
    subject(:doc) { indexer.to_solr }

    context 'when all fields are present' do
      it 'has none' do
        expect(doc).to eq('data_quality_ssim' => [])
      end
    end

    context 'with an invalid sourceId' do
      let(:xml) do
        <<~XML
          <identityMetadata>
            <sourceId source="RBC_TAN-2019F"/>
          </identityMetadata>
        XML
      end

      it 'draws the errors' do
        expect(doc).to eq(
          'data_quality_ssim' => ['non-comformant sourceId']
        )
      end
    end

    context 'with an failed conversion' do
      let(:cocina) { Failure(:nope) }

      it 'draws the errors' do
        expect(doc).to eq(
          'data_quality_ssim' => ['Cocina conversion failed']
        )
      end
    end
  end
end
