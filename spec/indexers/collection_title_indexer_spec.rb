# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionTitleIndexer do
  let(:druid) { 'druid:rt923jk3422' }
  let(:apo_id) { 'druid:bd999bd9999' }
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
        'isMemberOf' => []
      }
    )
  end

  let(:indexer) do
    described_class.new(cocina: cocina, parent_collections: collections)
  end

  describe '#to_solr' do
    let(:doc) { indexer.to_solr }
    let(:mock_rel_druid) { 'druid:qf999gg9999' }

    context 'when no collections are provided' do
      let(:collections) { [] }

      it "doesn't raise an error" do
        expect(doc[Solrizer.solr_name('collection_title', :symbol)]).to be_nil
        expect(doc[Solrizer.solr_name('collection_title', :stored_searchable)]).to be_nil
      end
    end

    context 'when related collections are provided' do
      let(:project) { 'Google Books' }
      let(:collections) { [collection] }

      let(:collection) do
        Cocina::Models.build(
          'externalIdentifier' => mock_rel_druid,
          'type' => Cocina::Models::Vocab.collection,
          'version' => 1,
          'label' => 'testing',
          'administrative' => {
            'partOfProject' => project,
            'hasAdminPolicy' => apo_id
          },
          'access' => {},
          'description' => {
            'title' => [{ 'value' => 'Test object' }]
          }
        )
      end

      it 'generate collection title fields' do
        expect(doc[Solrizer.solr_name('collection_title', :symbol)].first).to eq 'Test object'
        expect(doc[Solrizer.solr_name('collection_title', :stored_searchable)].first).to eq 'Test object'
      end
    end
  end
end