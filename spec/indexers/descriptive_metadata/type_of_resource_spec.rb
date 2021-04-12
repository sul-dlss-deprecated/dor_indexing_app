# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptiveMetadataIndexer do
  subject(:indexer) { described_class.new(cocina: cocina) }

  let(:cocina) { Cocina::Models.build(JSON.parse(json)) }
  let(:doc) { indexer.to_solr }
  let(:json) do
    <<~JSON
      {
        "type": "http://cocina.sul.stanford.edu/models/image.jsonld",
        "externalIdentifier": "druid:qy781dy0220",
        "label": "SUL Logo for forebrain",
        "version": 1,
        "access": {
          "access": "world",
          "copyright": "This work is copyrighted by the creator.",
          "download": "world",
          "useAndReproductionStatement": "This document is available only to the Stanford faculty, staff and student community."
        },
        "administrative": {
          "hasAdminPolicy": "druid:zx485kb6348",
          "partOfProject": "H2"
        },
        "description": #{JSON.generate(description)},
        "identification": {
          "sourceId": "hydrus:object-6"
        },
        "structural": {
          "contains": [{
            "type": "http://cocina.sul.stanford.edu/models/resources/file.jsonld",
            "externalIdentifier": "qy781dy0220_1",
            "label": "qy781dy0220_1",
            "version": 1,
            "structural": {
              "contains": [{
                "type": "http://cocina.sul.stanford.edu/models/file.jsonld",
                "externalIdentifier": "druid:qy781dy0220/sul-logo.png",
                "label": "sul-logo.png",
                "filename": "sul-logo.png",
                "size": 19823,
                "version": 1,
                "hasMimeType": "image/png",
                "hasMessageDigests": [{
                    "type": "sha1",
                    "digest": "b5f3221455c8994afb85214576bc2905d6b15418"
                  },
                  {
                    "type": "md5",
                    "digest": "7142ce948827c16120cc9e19b05acd49"
                  }
                ],
                "access": {
                  "access": "world",
                  "download": "world"
                },
                "administrative": {
                  "publish": true,
                  "sdrPreserve": true,
                  "shelve": true
                }
              }]
            }
          }],
          "isMemberOf": [
            "druid:nb022qg2431"
          ]
        }
      }
    JSON
  end

  describe 'form mappings from Cocina to Solr mods_typeOfResource_ssim' do
    context 'when one MODS resource type' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'text',
              type: 'resource type',
              source: {
                value: 'MODS resource types'
              }
            }
          ]
        }
      end

      xit 'includes value' do
        expect(doc).to include('mods_typeOfResource_ssim' => ['text'])
      end
    end

    context 'when multiple MODS resource types' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'text',
              type: 'resource type',
              source: {
                value: 'MODS resource types'
              }
            },
            {
              value: 'still image',
              type: 'resource type',
              source: {
                value: 'MODS resource types'
              }
            }
          ]
        }
      end

      xit 'includes values' do
        expect(doc).to include('mods_typeOfResource_ssim' => ['text', 'still image'])
      end
    end

    context 'when MODS resource type is collection' do
      # derives from MODS attribute, not value
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'collection',
              type: 'resource type',
              source: {
                value: 'MODS resource types'
              }
            }
          ]
        }
      end

      xit 'does not include value' do
        expect(doc).not_to include('mods_typeOfResource_ssim')
      end
    end

    context 'when MODS resource type is manuscript' do
      # derives from MODS attribute, not value
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'manuscript',
              type: 'resource type',
              source: {
                value: 'MODS resource types'
              }
            }
          ]
        }
      end

      xit 'does not includes value' do
        expect(doc).not_to include('mods_typeOfResource_ssim')
      end
    end

    context 'when form is not a MODS resource type' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'text',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'does not includes value' do
        expect(doc).not_to include('mods_typeOfResource_ssim')
      end
    end

    context 'when MODS resource type lacks type property' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'text',
              source: {
                value: 'MODS resource types'
              }
            }
          ]
        }
      end

      xit 'includes value' do
        expect(doc).to include('mods_typeOfResource_ssim' => ['text'])
      end
    end
  end
end
