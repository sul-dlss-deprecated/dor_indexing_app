# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataQualityIndexer do
  let(:rels_response) { instance_double(RestClient::Response, body: rels) }
  let(:identity_response) { instance_double(RestClient::Response, body: xml) }
  let(:rels_ext) { instance_double(Rubydora::Datastream, content: rels_response) }
  let(:identity_metadata) { instance_double(Rubydora::Datastream, content: identity_response) }

  let(:obj) do
    instance_double(Rubydora::DigitalObject,
                    models: ['info:fedora/fedora-system:FedoraObject-3.0', model],
                    datastreams: { 'RELS-EXT' => rels_ext, 'identityMetadata' => identity_metadata })
  end
  let(:model) { 'info:fedora/afmodel:Hydrus_Collection' }
  let(:indexer) do
    described_class.new(resource: obj)
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

  let(:rels) do
    <<~XML
      <rdf:RDF xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:hydra="http://projecthydra.org/ns/relations#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
        <rdf:Description rdf:about="info:fedora/druid:pt184zz3625">
          <hydra:isGovernedBy rdf:resource="info:fedora/druid:hh918nj2856"></hydra:isGovernedBy>
          <fedora-model:hasModel rdf:resource="info:fedora/afmodel:Hydrus_Collection"></fedora-model:hasModel>
        </rdf:Description>
      </rdf:RDF>
    XML
  end

  describe '#to_solr' do
    subject(:doc) { indexer.to_solr }

    context 'when all fields are present' do
      it 'has none' do
        expect(doc).to eq('data_quality_ssim' => ['Cocina conversion failed'])
      end
    end

    context 'when the object is part of an ETD' do
      context 'when it uses conforms_to (earlier ETD objects)' do
        let(:rels) do
          <<~XML
            <rdf:RDF xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:hydra="http://projecthydra.org/ns/relations#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
              <rdf:Description rdf:about="info:fedora/druid:pt184zz3625">
                <hydra:isGovernedBy rdf:resource="info:fedora/druid:hh918nj2856"></hydra:isGovernedBy>
                <fedora-model:conformsTo rdf:resource="info:fedora/afmodel:Part"></fedora-model:conformsTo>
              </rdf:Description>
            </rdf:RDF>
          XML
        end

        it 'has none' do
          expect(doc).to eq({})
        end
      end

      context 'when it uses has_model with Part (later ETD objects)' do
        let(:model) { 'info:fedora/afmodel:Part' }

        it 'has none' do
          expect(doc).to eq({})
        end
      end

      context 'when it uses has_model with PermissionFile (EEMs objects)' do
        let(:model) { 'info:fedora/afmodel:PermissionFile' }

        it 'has none' do
          expect(doc).to eq({})
        end
      end
    end

    context 'with an invalid sourceId for a DRO' do
      let(:xml) do
        <<~XML
          <identityMetadata>
            <sourceId source="RBC_TAN-2019F"/>
          </identityMetadata>
        XML
      end

      it 'draws the errors' do
        expect(doc).to eq(
          'data_quality_ssim' => ['non-comformant sourceId', 'Cocina conversion failed']
        )
      end
    end

    context 'without a sourceId' do
      let(:xml) do
        <<~XML
          <identityMetadata>
          </identityMetadata>
        XML
      end

      it 'draws the errors' do
        expect(doc).to eq(
          'data_quality_ssim' => ['Cocina conversion failed']
        )
      end
    end
  end
end
