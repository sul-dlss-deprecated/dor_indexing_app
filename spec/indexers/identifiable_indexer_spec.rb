# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentifiableIndexer do
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

  let(:druid) { 'druid:rt923jk3422' }
  let(:apo_id) { 'druid:bd999bd9999' }
  let(:collections) { [] }
  let(:cocina) do
    Cocina::Models.build(
      'externalIdentifier' => druid,
      'type' => Cocina::Models::Vocab.image,
      'version' => 1,
      'label' => 'testing',
      'access' => {},
      'administrative' => {
        'hasAdminPolicy' => apo_id
      },
      'description' => {
        'title' => [{ 'value' => 'Test obj' }],
        'subject' => [{ 'type' => 'topic', 'value' => 'word' }]
      },
      'structural' => {
        'contains' => [],
        'isMemberOf' => collections
      },
      'identification' => {
        'catalogLinks' => [{ 'catalog' => 'symphony', 'catalogRecordId' => '1234' }]
      }
    )
  end

  let(:indexer) do
    described_class.new(cocina: cocina)
  end

  before do
    described_class.reset_cache!
  end

  describe '#identity_metadata_source' do
    it 'indexes metadata source' do
      expect(indexer.identity_metadata_source).to eq 'Symphony'
    end
  end

  describe '#to_solr' do
    let(:doc) { indexer.to_solr }
    let(:mock_rel_druid) { 'druid:qf999gg9999' }
    # let(:collection) { instance_double(Dor::Collection, id: mock_rel_druid) }
    # let(:collections) { [collection] }

    let(:related) do
      instance_double(Cocina::Models::AdminPolicy, label: 'Test object')
    end
    let(:object_client) do
      instance_double(Dor::Services::Client::Object, find: related)
    end

    before do
      allow(object_client).to receive_message_chain(:administrative_tags, :list).and_return([])

      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    context 'when no collection is set' do
      let(:collections) { [] }

      it "doesn't raise an error" do
        expect(doc[Solrizer.solr_name('collection_title', :symbol)]).to be_nil
        expect(doc[Solrizer.solr_name('collection_title', :stored_searchable)]).to be_nil
        expect(doc[Solrizer.solr_name('apo_title', :symbol)]).to eq ['Test object']
        expect(doc[Solrizer.solr_name('apo_title', :stored_searchable)]).to eq ['Test object']
        expect(doc[Solrizer.solr_name('nonhydrus_apo_title', :symbol)]).to eq ['Test object']
        expect(doc[Solrizer.solr_name('nonhydrus_apo_title', :stored_searchable)]).to eq ['Test object']
      end
    end

    context 'when related collection and APOs are not found' do
      before do
        allow(Dor::Services::Client).to receive(:object).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      let(:collections) { [mock_rel_druid] }

      it 'generate collections and apo title fields' do
        expect(doc[Solrizer.solr_name('collection_title', :symbol)].first).to eq mock_rel_druid
        expect(doc[Solrizer.solr_name('collection_title', :stored_searchable)].first).to eq mock_rel_druid
        expect(doc[Solrizer.solr_name('apo_title', :symbol)].first).to eq apo_id
        expect(doc[Solrizer.solr_name('apo_title', :stored_searchable)].first).to eq apo_id
        expect(doc[Solrizer.solr_name('nonhydrus_apo_title', :symbol)].first).to eq apo_id
        expect(doc[Solrizer.solr_name('nonhydrus_apo_title', :stored_searchable)].first).to eq apo_id
      end
    end

    context 'when related collection and APOs are found' do
      let(:related) { instance_double(Cocina::Models::DRO, administrative: administrative, label: 'Test object') }
      let(:administrative) { instance_double(Cocina::Models::Administrative, partOfProject: project) }
      let(:project) { 'Google Books' }
      let(:collections) { [mock_rel_druid] }

      it 'generate collections and apo title fields' do
        expect(doc[Solrizer.solr_name('collection_title', :symbol)].first).to eq 'Test object'
        expect(doc[Solrizer.solr_name('collection_title', :stored_searchable)].first).to eq 'Test object'
        expect(doc[Solrizer.solr_name('apo_title', :symbol)].first).to eq 'Test object'
        expect(doc[Solrizer.solr_name('apo_title', :stored_searchable)].first).to eq 'Test object'
        expect(doc[Solrizer.solr_name('nonhydrus_apo_title', :symbol)].first).to eq 'Test object'
        expect(doc[Solrizer.solr_name('nonhydrus_apo_title', :stored_searchable)].first).to eq  'Test object'
      end

      it 'indexes metadata source' do
        expect(doc).to match a_hash_including('metadata_source_ssi' => 'Symphony')
      end
    end
  end
end
