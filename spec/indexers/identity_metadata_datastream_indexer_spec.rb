# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentityMetadataDatastreamIndexer do
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

  let(:obj) { Dor::Item.new(pid: 'druid:rt923jk342') }

  let(:indexer) do
    described_class.new(resource: obj)
  end

  before do
    obj.identityMetadata.content = xml
  end

  describe '#to_solr' do
    subject(:doc) { indexer.to_solr }

    it 'has the fields used by argo' do
      expect(doc).to include(
        'barcode_id_ssim' => ['36105049267078'],
        'catkey_id_ssim' => ['129483625'],
        'dor_id_tesim' => %w[STANFORD_342837261527 36105049267078 129483625
                             7f3da130-7b02-11de-8a39-0800200c9a66],
        'exploded_tag_ssim' => ['Google Books', 'Google Books : Phase 1', 'Google Books',
                                'Google Books : Scan source STANFORD', 'Project', 'Project : Beautiful Books',
                                'Registered By', 'Registered By : blalbrit', 'DPG', 'DPG : Beautiful Books',
                                'DPG : Beautiful Books : Octavo', 'DPG : Beautiful Books : Octavo : newpri',
                                'Remediated By', 'Remediated By : 4.15.4'],
        'identifier_ssim' => ['google:STANFORD_342837261527', 'barcode:36105049267078',
                              'catkey:129483625', 'uuid:7f3da130-7b02-11de-8a39-0800200c9a66'],
        'identifier_tesim' => ['google:STANFORD_342837261527', 'barcode:36105049267078',
                               'catkey:129483625', 'uuid:7f3da130-7b02-11de-8a39-0800200c9a66'],
        'objectType_ssim' => ['item'],
        'project_tag_ssim' => ['Beautiful Books'],
        'registered_by_tag_ssim' => ['blalbrit'],
        'source_id_ssim' => ['google:STANFORD_342837261527'],
        'tag_ssim' => ['Google Books : Phase 1', 'Google Books : Scan source STANFORD',
                       'Project : Beautiful Books', 'Registered By : blalbrit',
                       'DPG : Beautiful Books : Octavo : newpri',
                       'Remediated By : 4.15.4']
      )
    end
  end
end
