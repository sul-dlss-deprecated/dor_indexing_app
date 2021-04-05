# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptiveMetadataIndexer do
  subject(:indexer) { described_class.new(cocina: cocina) }

  let(:cocina) { Cocina::Models.build(JSON.parse(json)) }
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
  let(:doc) { indexer.to_solr }

  describe 'genre mappings from Cocina to Solr sw_genre_ssim' do
    context 'when single genre' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          form: [
            {
              value: 'photographs',
              type: 'genre'
            }
          ]
        }
      end

      xit 'uses genre value' do
        expect(doc).to include('sw_genre_ssim' => ['photographs'])
      end
    end

    context 'when multiple genres' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          form: [
            {
              value: 'photographs',
              type: 'genre'
            },
            {
              value: 'ambrotypes',
              type: 'genre'
            }
          ]
        }
      end

      xit 'uses both genre values' do
        expect(doc).to include('sw_genre_ssim' => %w[photographs ambrotypes])
      end
    end

    context 'when multilingual' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          form: [
            {
              parallelValue: [
                {
                  value: 'photographs',
                  type: 'genre'
                },
                {
                  value: 'фотографии',
                  type: 'genre'
                }
              ]
            }
          ]
        }
      end

      xit 'uses both genre values' do
        expect(doc).to include('sw_genre_ssim' => %w[photographs фотографии])
      end
    end

    context 'when genre term is capitalized' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          form: [
            {
              value: 'Photographs',
              type: 'genre',
              displayLabel: 'Image type'
            }
          ]
        }
      end

      xit 'retains capitalization in Solr' do
        expect(doc).to include('sw_genre_ssim' => ['Photographs'])
      end
    end

    context 'when thesis (case-insensitive)' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          form: [
            {
              value: 'Thesis',
              type: 'genre'
            }
          ]
        }
      end

      xit 'retains capitalization in Solr' do
        expect(doc).to include('sw_genre_ssim' => ['Thesis'])
      end
    end

    context 'when conference publication (case-insensitive)' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          form: [
            {
              value: 'Conference Publication',
              type: 'genre'
            }
          ]
        }
      end

      xit 'retains capitalization in Solr' do
        expect(doc).to include('sw_genre_ssim' => ['Conference proceedings'])
      end
    end

    context 'when government publication (case-insensitive)' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          form: [
            {
              value: 'Government publication',
              type: 'genre'
            }
          ]
        }
      end

      xit 'retains capitalization in Solr' do
        expect(doc).to include('sw_genre_ssim' => ['Government document'])
      end
    end

    context 'when technical report (case-insensitive)' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          form: [
            {
              value: 'technical report',
              type: 'genre'
            }
          ]
        }
      end

      xit 'retains capitalization in Solr' do
        expect(doc).to include('sw_genre_ssim' => ['Technical report'])
      end
    end
  end
end
