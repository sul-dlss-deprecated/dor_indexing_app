# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContentMetadataDatastreamIndexer do
  let(:xml) do
    <<~XML
            <?xml version="1.0"?>
      <contentMetadata objectId="druid:gw177fc7976" type="map" stacks="/specialstack">
      <resource id="0001" sequence="1" type="image">
      <file format="JPEG2000" id="gw177fc7976_05_0001.jp2" mimetype="image/jp2" preserve="yes" publish="yes" shelve="yes" size="5143883">
      <imageData height="4580" width="5939"/>
      <checksum type="md5">3d3ff46d98f3d517d0bf086571e05c18</checksum>
      <checksum type="sha1">ca1eb0edd09a21f9dd9e3a89abc790daf4d04916</checksum>
      </file>
      <file format="GIF" id="gw177fc7976_05_0001.gif" mimetype="image/gif" preserve="no" publish="no" shelve="no" size="4128877" role="derivative">
      <imageData height="4580" width="5939"/>
      <checksum type="md5">406d5d80fdd9ecc0352d339badb4a8fb</checksum>
      <checksum type="sha1">61940d4fad097cba98a3e9dd9f12a90dde0be1ac</checksum>
      </file>
      <file format="TIFF" id="gw177fc7976_00_0001.tif" mimetype="image/tiff" preserve="yes" publish="no" shelve="no" size="81630420">
      <imageData height="4580" width="5939"/>
      <checksum type="md5">81ccd17bccf349581b779615e82a0366</checksum>
      <checksum type="sha1">12586b624540031bfa3d153299160c4885c3508c</checksum>
      </file>
      </resource>
      </contentMetadata>
    XML
  end

  let(:json) do
    <<~JSON
      {
        "type": "http://cocina.sul.stanford.edu/models/map.jsonld",
        "externalIdentifier": "druid:cs178jh7817",
        "label": "Some more screenshots",
        "version": 1,
        "access": {
          "access": "world",
          "download": "world"
        },
        "administrative": {
          "hasAdminPolicy": "druid:zx485kb6348"
        },
        "identification": {
          "sourceId": "hydrus:72"
        },
        "structural": {
          "contains": [
            {
              "type": "http://cocina.sul.stanford.edu/models/fileset.jsonld",
              "externalIdentifier": "0001",
              "label": "0001",
              "version": 1,
              "structural": {
                "contains": [
                  {
                    "type": "http://cocina.sul.stanford.edu/models/file.jsonld",
                    "externalIdentifier": "druid:cs178jh7817/gw177fc7976_05_0001.jp2",
                    "label": "gw177fc7976_05_0001.jp2",
                    "filename": "gw177fc7976_05_0001.jp2",
                    "size": 5143883,
                    "version": 1,
                    "hasMimeType": "image/jp2",
                    "hasMessageDigests": [
                      {
                        "type": "sha1",
                        "digest": "ca1eb0edd09a21f9dd9e3a89abc790daf4d04916"
                      },
                      {
                        "type": "md5",
                        "digest": "3d3ff46d98f3d517d0bf086571e05c18"
                      }
                    ],
                    "access": {
                      "access": "world",
                      "download": "world"
                    },
                    "administrative": {
                      "sdrPreserve": true,
                      "shelve": true
                    },
                    "presentation": {
                      "height": 4580,
                      "width": 5939
                    }
                  },
                  {
                    "type": "http://cocina.sul.stanford.edu/models/file.jsonld",
                    "externalIdentifier": "druid:cs178jh7817/gw177fc7976_05_0001.gif",
                    "label": "gw177fc7976_05_0001.gif",
                    "filename": "gw177fc7976_05_0001.gif",
                    "size": 4128877,
                    "version": 1,
                    "hasMimeType": "image/gif",
                    "use": "derivative",
                    "hasMessageDigests": [
                      {
                        "type": "sha1",
                        "digest": "61940d4fad097cba98a3e9dd9f12a90dde0be1ac"
                      },
                      {
                        "type": "md5",
                        "digest": "406d5d80fdd9ecc0352d339badb4a8fb"
                      }
                    ],
                    "access": {
                      "access": "dark",
                      "download": "none"
                    },
                    "administrative": {
                      "sdrPreserve": false,
                      "shelve": false
                    },
                    "presentation": {
                      "height": 4580,
                      "width": 5939
                    }
                  },
                  {
                    "type": "http://cocina.sul.stanford.edu/models/file.jsonld",
                    "externalIdentifier": "druid:cs178jh7817/gw177fc7976_00_0001.tif",
                    "label": "gw177fc7976_00_0001.tif",
                    "filename": "gw177fc7976_00_0001.tif",
                    "size": 81630420,
                    "version": 1,
                    "hasMimeType": "image/tiff",
                    "hasMessageDigests": [
                      {
                        "type": "sha1",
                        "digest": "12586b624540031bfa3d153299160c4885c3508c"
                      },
                      {
                        "type": "md5",
                        "digest": "81ccd17bccf349581b779615e82a0366"
                      }
                    ],
                    "access": {
                      "access": "dark",
                      "download": "none"
                    },
                    "administrative": {
                      "sdrPreserve": true,
                      "shelve": false
                    },
                    "presentation": {
                      "height": 4580,
                      "width": 5939
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    JSON
  end

  let(:cocina) { Cocina::Models.build(JSON.parse(json)) }
  let(:obj) { Dor::Item.new }

  let(:indexer) do
    described_class.new(id: 'druid:ab123cd4567', resource: obj, cocina: cocina)
  end

  before do
    obj.contentMetadata.content = xml
  end

  describe '#to_solr' do
    subject(:doc) { indexer.to_solr }

    it 'has the fields used by argo' do
      expect(doc).to include(
        'content_type_ssim' => 'map',
        'content_file_mimetypes_ssim' => ['image/jp2', 'image/gif', 'image/tiff'],
        'content_file_roles_ssim' => ['derivative'],
        'shelved_content_file_count_itsi' => 1,
        'resource_count_itsi' => 1,
        'content_file_count_itsi' => 3,
        'image_resource_count_itsi' => 1,
        'first_shelved_image_ss' => 'gw177fc7976_05_0001.jp2',
        'preserved_size_dbtsi' => 86_774_303
      )
    end
  end
end
