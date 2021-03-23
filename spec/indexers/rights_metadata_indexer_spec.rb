# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RightsMetadataIndexer do
  let(:xml) do
    <<~XML
      <?xml version="1.0"?>
      <rightsMetadata>
        <access type="discover">
          <machine>
            <world/>
          </machine>
        </access>
        <access type="read">
          <machine>
            <world/>
          </machine>
        </access>
        <use>
          <human type="useAndReproduction">Official WTO documents are free for public use.</human>
          <human type="creativeCommons"/>
          <machine type="creativeCommons">by-nc-nd</machine>
        </use>
        <copyright>
          <human>Copyright &#xA9; World Trade Organization</human>
        </copyright>
      </rightsMetadata>
    XML
  end

  let(:apo_id) { 'druid:gf999hb9999' }
  let(:druid) { 'druid:rt923jk3421' }
  let(:obj) { Dor::Item.new(pid: druid) }
  let(:rights_md_ds) { obj.rightsMetadata }
  let(:cocina) do
    Cocina::Models.build(
      'type' => Cocina::Models::Vocab.object,
      'externalIdentifier' => druid,
      'label' => 'testing read access rights',
      'version' => 1,
      'access' => {
        'access' => 'world',
        'copyright' => 'Copyright &#xA9; World Trade Organization',
        'useAndReproductionStatement' => 'Official WTO documents are free for public use.',
        'license' => 'by-nc-nd'
      },
      'administrative' => {
        'hasAdminPolicy' => apo_id
      },
      'description' => {
        'title' => [{ 'value' => 'complex read access rights' }]
      }
    )
  end

  let(:indexer) do
    described_class.new(resource: obj, cocina: cocina)
  end

  before do
    rights_md_ds.content = xml
  end

  describe '#to_solr' do
    subject(:doc) { indexer.to_solr }

    it 'has the fields used by argo' do
      expect(doc).to include(
        'copyright_ssim' => ['Copyright © World Trade Organization'],
        'use_statement_ssim' => ['Official WTO documents are free for public use.'],
        'use_license_machine_ssi' => 'by-nc-nd',
        'rights_descriptions_ssim' => ['world'] # Access Rights facet, display and search
      )
    end

    describe 'legacy tests to_solr' do
      let(:mock_dra_obj) { instance_double(Dor::RightsAuth, index_elements: index_elements) }

      before do
        allow(rights_md_ds).to receive(:dra_object).and_return(mock_dra_obj)
      end

      # FIXME: is the only 'rule' we use "no-download"?  Or do we use for location and file specific stuff?

      context 'when access is restricted' do
        let(:index_elements) do
          {
            primary: 'access_restricted',
            errors: [],
            terms: [],
            obj_locations_qualified: [{ location: 'someplace', rule: 'somerule' }],
            file_groups_qualified: [{ group: 'somegroup', rule: 'someotherrule' }]
          }
        end

        it 'filters access_restricted from what gets aggregated into rights_descriptions_ssim' do
          expect(doc).to match a_hash_including(
            'rights_descriptions_ssim' => ['location: someplace (somerule)', 'somegroup (file) (someotherrule)']
          )
        end
      end

      context 'when it is world qualified' do
        let(:index_elements) do
          {
            primary: 'world_qualified',
            errors: [],
            terms: [],
            obj_world_qualified: [{ rule: 'somerule' }]
          }
        end

        it 'filters world_qualified from what gets aggregated into rights_descriptions_ssim' do
          expect(doc).to match a_hash_including(
            'rights_descriptions_ssim' => ['world (somerule)']
          )
        end
      end

      context 'when it is controlled digital lending' do
        let(:index_elements) do
          {
            primary: 'cdl_none',
            errors: [],
            terms: []
          }
        end

        it 'indexes correctly into rights_descriptions_ssim' do
          expect(doc).to match a_hash_including(
            'rights_descriptions_ssim' => ['controlled digital lending']
          )
        end
      end
    end
  end

  context 'when cocina access value alone' do
    subject(:doc) { indexer.cocina_to_solr }

    # Note that cocina-model is validated so bad values for the enum should never appear
    # location-based is tested below
    {
      'dark' => 'dark',
      'citation-only' => 'citation',
      'stanford' => 'stanford (no-download)', # download defaults to none
      'world' => 'world (no-download)'
    }.each_pair do |cocina_access_val, index_val|
      describe '#cocina_to_solr' do
        let(:cocina) do
          Cocina::Models.build(
            'type' => Cocina::Models::Vocab.object,
            'externalIdentifier' => druid,
            'label' => 'testing cocina.access.access rights',
            'version' => 1,
            'access' => {
              'access' => cocina_access_val
            },
            'administrative' => {
              'hasAdminPolicy' => apo_id
            },
            'description' => {
              'title' => [{ 'value' => 'testing cocina.access.access rights' }]
            }
          )
        end

        it "indexes #{cocina_access_val} correctly into rights_descriptions_ssim" do
          expect(doc['rights_descriptions_ssim']).to eq [index_val]
        end
      end
    end
  end

  context 'when cocina access location-based and readLocation is set' do
    # Fedora examples from real objects
    # xml1 = <<~XML
    #   <rightsMetadata>
    #     <access type="discover">
    #       <machine>
    #         <world/>
    #       </machine>
    #     </access>
    #     <access type="read">
    #       <machine>
    #         <location>hoover</location>
    #       </machine>
    #     </access>
    #     <copyright>
    #       <human type="copyright">This work is protected by copyright. blah</human>
    #     </copyright>
    #   </rightsMetadata>
    # XML

    # xml2 = <<~XML
    #   <rightsMetadata>
    #     <access type="discover">
    #       <machine>
    #         <world/>
    #       </machine>
    #     </access>
    #     <access type="read">
    #       <machine>
    #         <location rule="no-download">music</location>
    #       </machine>
    #     </access>
    #     <use>
    #       <human type="useAndReproduction">Property rights reside with the repository. blah</human>
    #     </use>
    #     <use>
    #       <human type="creativeCommons"/>
    #       <machine type="creativeCommons"/>
    #     </use>
    #   </rightsMetadata>
    # XML

    # Note that cocina-model is validated so bad values for the enum should never appear
    ['spec', 'music', 'ars', 'art', 'hoover', 'm&m'].each do |location|
      describe '#cocina_to_solr' do
        subject(:doc) { indexer.cocina_to_solr }

        let(:cocina) do
          Cocina::Models.build(
            'type' => Cocina::Models::Vocab.object,
            'externalIdentifier' => druid,
            'label' => 'testing no download rights',
            'version' => 1,
            'access' => {
              'access' => 'location-based',
              'download' => 'location-based',
              'readLocation' => location
            },
            'administrative' => {
              'hasAdminPolicy' => apo_id
            },
            'description' => {
              'title' => [{ 'value' => 'no download rights' }]
            }
          )
        end

        it 'indexes the location specific access correctly' do
          expect(doc['rights_descriptions_ssim']).to eq(["location: #{location}"])
        end
      end
    end

    xit 'FIXME: what should happen if no readLocation?  Can we cocina validate this case away?'
  end

  context 'when cocina file level permissions' do
    # Fedora example from real object
    # xml = <<~XML
    #   <rightsMetadata>
    #     <access type="discover">
    #       <machine>
    #         <world/>
    #       </machine>
    #     </access>
    #     <access type="read">
    #       <machine>
    #         <location>ars</location>
    #       </machine>
    #     </access>
    #     <access type="read">
    #       <file>bz456nt9947_listing_pm.xlsx</file>
    #       <machine>
    #         <group>stanford</group>
    #       </machine>
    #     </access>
    #   </rightsMetadata>
    # XML

    xit 'to be implemented after cocina can model file level rights - see https://github.com/sul-dlss/dor-services-app/pull/2402'
  end

  # FIXME:  is it true that download will either match access value OR it will be none, but no other value makes sense?
  describe 'cocina-access.download' do
    subject(:doc) { indexer.cocina_to_solr }

    xit 'implement no-download for file restricted: "stanford (file) (no-download)", "world (file) (no-download)" and "location (file) (no-download)"'

    ['world', 'stanford'].each do |level|
      context "when cocina access and download are both #{level}" do
        let(:cocina) do
          Cocina::Models.build(
            'type' => Cocina::Models::Vocab.object,
            'externalIdentifier' => druid,
            'label' => 'testing no download rights',
            'version' => 1,
            'access' => {
              'access' => level,
              'download' => level
            },
            'administrative' => {
              'hasAdminPolicy' => apo_id
            },
            'description' => {
              'title' => [{ 'value' => 'no download rights' }]
            }
          )
        end

        it "indexes correctly as #{level}" do
          expect(doc['rights_descriptions_ssim']).to eq([level])
        end
      end
    end

    context 'when location-based access and location-based download' do
      let(:cocina) do
        Cocina::Models.build(
          'type' => Cocina::Models::Vocab.object,
          'externalIdentifier' => druid,
          'label' => 'testing no download rights',
          'version' => 1,
          'access' => {
            'access' => 'location-based',
            'readLocation' => 'music',
            'download' => 'location-based'
          },
          'administrative' => {
            'hasAdminPolicy' => apo_id
          },
          'description' => {
            'title' => [{ 'value' => 'no download rights' }]
          }
        )
      end

      it 'indexes correctly with location' do
        expect(doc['rights_descriptions_ssim']).to eq(['location: music'])
      end
    end

    context 'when citation-only access and download "none"' do
      let(:cocina) do
        Cocina::Models.build(
          'type' => Cocina::Models::Vocab.object,
          'externalIdentifier' => druid,
          'label' => 'testing no download rights',
          'version' => 1,
          'access' => {
            'access' => 'citation-only',
            'download' => 'none'
          },
          'administrative' => {
            'hasAdminPolicy' => apo_id
          },
          'description' => {
            'title' => [{ 'value' => 'no download rights' }]
          }
        )
      end

      it 'indexes as "citation"' do
        expect(doc['rights_descriptions_ssim']).to eq(['citation'])
      end
    end

    context 'when world access and no-download' do
      let(:cocina) do
        Cocina::Models.build(
          'type' => Cocina::Models::Vocab.object,
          'externalIdentifier' => druid,
          'label' => 'testing no download rights',
          'version' => 1,
          'access' => {
            'access' => 'world',
            'download' => 'none'
          },
          'administrative' => {
            'hasAdminPolicy' => apo_id
          },
          'description' => {
            'title' => [{ 'value' => 'no download rights' }]
          }
        )
      end

      it 'indexes correctly with world and no-download indicated' do
        expect(doc['rights_descriptions_ssim']).to eq(['world (no-download)'])
      end
    end

    context 'when stanford access and no-download' do
      # example xml
      # <access type="read">
      #   <machine>
      #     <group>stanford</group>
      #   </machine>
      # </access>
      let(:cocina) do
        Cocina::Models.build(
          'type' => Cocina::Models::Vocab.object,
          'externalIdentifier' => druid,
          'label' => 'testing no download rights',
          'version' => 1,
          'access' => {
            'access' => 'stanford',
            'download' => 'none'
          },
          'administrative' => {
            'hasAdminPolicy' => apo_id
          },
          'description' => {
            'title' => [{ 'value' => 'no download rights' }]
          }
        )
      end

      it 'indexes correctly with stanford and no-download indicated' do
        expect(doc['rights_descriptions_ssim']).to eq(['stanford (no-download)'])
      end
    end

    context 'when location restricted access and no-download' do
      # example xml
      # <rightsMetadata>
      #   <access type="discover">
      #     <machine>
      #       <world/>
      #     </machine>
      #   </access>
      #   <access type="read">
      #     <machine>
      #       <location rule="no-download">music</location>
      #     </machine>
      #   </access>
      # </access>
      let(:cocina) do
        Cocina::Models.build(
          'type' => Cocina::Models::Vocab.object,
          'externalIdentifier' => druid,
          'label' => 'testing no download rights',
          'version' => 1,
          'access' => {
            'access' => 'location-based',
            'readLocation' => 'music',
            'download' => 'none'
          },
          'administrative' => {
            'hasAdminPolicy' => apo_id
          },
          'description' => {
            'title' => [{ 'value' => 'no download rights' }]
          }
        )
      end

      it 'indexes correctly with location and no-download indicated' do
        expect(doc['rights_descriptions_ssim']).to eq(['location: music (no-download)'])
      end
    end
  end

  context 'when controlled digital lending' do
    # rightsMetadata currently like this:
    # xml = <<~XML
    #   <rightsMetadata>
    #     <access type="discover">
    #       <machine>
    #         <world/>
    #       </machine>
    #     </access>
    #     <access type="read">
    #       <machine>
    #         <cdl>
    #           <group rule="no-download">stanford</group>
    #         </cdl>
    #       </machine>
    #     </access>
    #   </rightsMetadata>
    # XML

    let(:cocina) do
      Cocina::Models.build(
        'type' => Cocina::Models::Vocab.object,
        'externalIdentifier' => druid,
        'label' => 'testing controlled digital lending rights',
        'version' => 1,
        'access' => {
          'access' => 'stanford',
          'download' => 'stanford',
          'controlledDigitalLending' => true
        },
        'administrative' => {
          'hasAdminPolicy' => apo_id
        },
        'description' => {
          'title' => [{ 'value' => 'controlled digital lending rights' }]
        }
      )
    end

    describe '#cocina_to_solr' do
      subject(:doc) { indexer.cocina_to_solr }

      it 'indexes correctly into rights_descriptions_ssim' do
        expect(doc['rights_descriptions_ssim'].size).to eq 2
        expect(doc['rights_descriptions_ssim']).to include('controlled digital lending')
        expect(doc['rights_descriptions_ssim']).to include('stanford')
      end
    end
  end

  context 'with combined complexities' do
    context 'when read rights are stanford, world (no-download), world (file)' do
      let(:druid) { 'druid:nn734fw1198' }
      # rightsMetadata currently like this:
      let(:xml) do
        <<~XML
          <rightsMetadata>
            <access type="discover">
              <machine>
                <world/>
              </machine>
            </access>
            <access type="read">
              <machine>
                <group>stanford</group>
              </machine>
            </access>
            <access type="read">
              <machine>
                <world rule="no-download"/>
              </machine>
            </access>
            <access type="read">
              <file>nn734fw1198_md.pdf</file>
              <machine>
                <world/>
              </machine>
            </access>
          </rightsMetadata>
        XML
      end

      let(:cocina) do
        Cocina::Models.build(
          'type' => Cocina::Models::Vocab.object,
          'externalIdentifier' => druid,
          'label' => 'testing read access rights',
          'version' => 1,
          'access' => {
            'access' => 'world'
          },
          'administrative' => {
            'hasAdminPolicy' => apo_id
          },
          'description' => {
            'title' => [{ 'value' => 'complex read access rights' }]
          }
        )
      end

      describe '#cocina_to_solr' do
        subject(:doc) { indexer.cocina_to_solr }

        xit 'has the fields used by argo' do
          expect(doc).to include(
            'copyright_ssim' => [],
            'use_statement_ssim' => [],
            'use_license_machine_ssi' => nil,
            'rights_descriptions_ssim' => ['stanford', 'world (no-download)', 'world (file)']
          )
        end
      end
    end
  end
end
