# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FallbackIndexer do
  describe '#to_solr' do
    subject(:solr_doc) { indexer.to_solr }

    let(:indexer) { described_class.new(id: apo_id) }
    let(:apo_id) { 'druid:bd999bd9999' }
    let(:apo_object_client) { instance_double(Dor::Services::Client::Object) }
    let(:workflows) do
      instance_double(WorkflowsIndexer, to_solr: { 'wf_ssim' => ['accessionWF'] })
    end

    let(:obj) do
      instance_double(Rubydora::DigitalObject,
                      label: nil,
                      pid: apo_id,
                      lastModifiedDate: '2021-04-23T21:59:20.528Z',
                      models: ['info:fedora/fedora-system:FedoraObject-3.0', model],
                      datastreams: { 'RELS-EXT' => rels_ext,
                                     'identityMetadata' => identity_metadata,
                                     'versionMetadata' => version_metadata })
    end
    let(:model) { 'info:fedora/afmodel:Hydrus_Collection' }
    let(:connection) { instance_double(Rubydora::Repository, find: obj) }

    let(:rels_response) { instance_double(RestClient::Response, body: rels) }
    let(:identity_response) { instance_double(RestClient::Response, body: xml) }
    let(:version_response) { instance_double(RestClient::Response, body: version) }
    let(:rels_ext) { instance_double(Rubydora::Datastream, content: rels_response) }
    let(:identity_metadata) { instance_double(Rubydora::Datastream, content: identity_response) }
    let(:version_metadata) { instance_double(Rubydora::Datastream, content: version_response) }

    let(:version) do
      <<~XML
        <versionMetadata>
          <version versionId="1" tag="1.0.0"></version>
          <version versionId="2" tag="2.0.0"></version>
        </versionMetadata>
      XML
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

    before do
      allow(Rubydora).to receive(:connect).and_return(connection)
      allow(Dor::Services::Client).to receive(:object).with(apo_id).and_return(apo_object_client)
      allow(WorkflowsIndexer).to receive(:new).and_return(workflows)
      allow(WorkflowFields).to receive(:for).and_return({ 'milestones_ssim' => %w[foo bar] })
      allow(apo_object_client).to receive_message_chain(:administrative_tags, :list).and_return([])
    end

    it 'creates the solr document' do
      expect(solr_doc).to include('milestones_ssim', 'wf_ssim', 'tag_ssim', 'obj_label_tesim', 'has_model_ssim', :id)
      expect(solr_doc['objectId_tesim']).to eq ['druid:bd999bd9999', 'bd999bd9999']
    end
  end
end
