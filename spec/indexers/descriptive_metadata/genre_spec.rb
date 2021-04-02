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
        "description": {
          #{description}
        },
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

  describe 'genre mappings from Cocina to Solr' do
    describe 'sw_genre_ssim' do
      let(:doc) { indexer.to_solr }

      context 'when single genre' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "title"
              }
            ],
            "genre": [
              {
                "value": "photographs"
              }
            ]
          JSON
        end

        xit 'populates sw_genre_ssim' do
          expect(doc).to include('sw_genre_ssim' => ['photographs'])
        end
      end

      context 'when multiple genres' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "title"
              }
            ],
            "genre": [
              {
                "value": "photographs"
              },
              {
                "value": "ambrotypes"
              }
            ]
          JSON
        end

        xit 'populates sw_genre_ssim' do
          expect(doc).to include('sw_genre_ssim' => %w[photographs ambrotypes])
        end
      end

      context 'when genre with additional property' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "title"
              }
            ],
            "genre": [
              {
                "value": "Photographs",
                "displayLabel": "Image type"
              }
            ]
          JSON
        end

        xit 'populates sw_genre_ssim' do
          expect(doc).to include('sw_genre_ssim' => ['Photographs'])
        end
      end

      context 'when thesis (case-insensitive)' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "title"
              }
            ],
            "genre": [
              {
                "value": "Thesis"
              }
            ]
          JSON
        end

        xit 'populates sw_genre_ssim' do
          expect(doc).to include('sw_genre_ssim' => ['Thesis'])
        end
      end

      context 'when conference publication (case-insensitive)' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "title"
              }
            ],
            "genre": [
              {
                "value": "Conference Publication"
              }
            ]
          JSON
        end

        xit 'populates sw_genre_ssim' do
          expect(doc).to include('sw_genre_ssim' => ['Conference proceedings'])
        end
      end

      context 'when government publication (case-insensitive)' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "title"
              }
            ],
            "genre": [
              {
                "value": "Government publication"
              }
            ]
          JSON
        end

        xit 'populates sw_genre_ssim' do
          expect(doc).to include('sw_genre_ssim' => ['Government document'])
        end
      end

      context 'when technical report (case-insensitive)' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "title"
              }
            ],
            "genre": [
              {
                "value": "technical report"
              }
            ]
          JSON
        end

        xit 'populates sw_genre_ssim' do
          expect(doc).to include('sw_genre_ssim' => ['Technical report'])
        end
      end
    end
  end
end
