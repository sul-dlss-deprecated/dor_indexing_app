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

  describe 'date mappings from Cocina to Solr' do
    describe 'origin_info_date_created_tesim' do
      # Creation date
      let(:doc) { indexer.to_solr }

      context 'when date.type creation and date.status primary' do
        # Select date.type creation with date.status primary
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title"
              }
            ],
            "event": [
              {
                "date": [
                  {
                    "value": "1900",
                    "type": "creation",
                    "status": "primary"
                  }
                ]
              }
            ]
          JSON
        end

        xit 'populates origin_info_date_created_tesim' do
          expect(doc).to include('origin_info_date_created_tesim' => '1900')
        end
      end

      context 'when one date.type creation and other date type has date.status primary' do
        # Select date.type creation if other date.type is primary
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title"
              }
            ],
            "event": [
              {
                "date": [
                  {
                    "value": "1900",
                    "type": "creation"
                  },
                  {
                    "value": "1905",
                    "type": "publication",
                    "status": "primary"
                  }
                ]
              }
            ]
          JSON
        end

        xit 'populates origin_info_date_created_tesim' do
          expect(doc).to include('origin_info_date_created_tesim' => '1900')
        end
      end

      context 'when event.type creation and date.type not creation' do
        # Do not select
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title"
              }
            ],
            "event": [
              {
                "type": "creation",
                "date": [
                  {
                    "value": "1900",
                    "type": "publication"
                  }
                ]
              }
            ]
          JSON
        end

        xit 'populates origin_info_date_created_tesim' do
          expect(doc).not_to include('origin_info_date_created_tesim')
        end
      end

      context 'when multiple date.type creation and no date.status primary' do
        # Select first date with date.type creation
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title"
              }
            ],
            "event": [
              {
                "date": [
                  {
                    "value": "1900",
                    "type": "creation"
                  }
                ]
              },
              {
                "date": [
                  {
                    "value": "1905",
                    "type": "creation"
                  }
                ]
              }
            ]
          JSON
        end

        # Currently array - make single-valued
        xit 'populates origin_info_date_created_tesim' do
          expect(doc).to include('origin_info_date_created_tesim' => '1900')
        end
      end

      context 'when no date.type creation and only event.type creation has date with no type' do
        # Select date without date.type from event with event.type creation
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title"
              }
            ],
            "event": [
              {
                "type": "creation",
                "date": [
                  {
                    "value": "1900"
                  }
                ]
              },
              {
                "type": "publication",
                "date": [
                  {
                    "value": "1905"
                  }
                ]
              }

            ]
          JSON
        end

        xit 'populates origin_info_date_created_tesim' do
          expect(doc).to include('origin_info_date_created_tesim' => '1900')
        end
      end

      context 'when event.type not creation has only date.type creation in record' do
        # Select date.type creation
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title"
              }
            ],
            "event": [
              {
                "type": "publication",
                "date": [
                  {
                    "value": "1900",
                    "type": "creation"
                  },
                  {
                    "value": "1905",
                    "type": "publication"
                  }
                ]
              }
            ]
          JSON
        end

        xit 'populates origin_info_date_created_tesim' do
          expect(doc).to include('origin_info_date_created_tesim' => '1900')
        end
      end

      context 'when no event.type creation and no date.type creation' do
        # Do not select
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title"
              }
            ],
            "event": [
              {
                "type": "publication",
                "date": [
                  {
                    "value": "1900",
                    "type": "publication",
                    "status": "primary"
                  }
                ]
              }
            ]
          JSON
        end

        xit 'populates origin_info_date_created_tesim' do
          expect(doc).not_to include('origin_info_date_created_tesim')
        end
      end

      context 'when creation date is range' do
        # Select first value in range
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title"
              }
            ],
            "event": [
              {
                "type": "creation",
                "date": [
                  {
                    "structuredValue": [
                      {
                        "value": "1900",
                        "type": "start"
                      },
                      {
                        "value": "1905",
                        "type": "end"
                      }
                    ],
                    "type": "creation",
                    "status": "primary"
                  }
                ]
              }
            ]
          JSON
        end

        xit 'populates origin_info_date_created_tesim' do
          expect(doc).to include('origin_info_date_created_tesim' => '1900')
        end
      end

      context 'when creation date is in parallelValue' do
        # Select first creation date in parallelValue
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title"
              }
            ],
            "event": [
              {
                "date": [
                  {
                    "parallelValue": [
                      {
                        "value": "1900-04-02",
                        "note": [
                          {
                            "value": "Gregorian",
                            "type": "calendar"
                          }
                        ]
                      },
                      {
                        "value": "1900-03-20",
                        "note": [
                          {
                            "value": "Julian",
                            "type": "calendar"
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          JSON
        end

        xit 'populates origin_info_date_created_tesim' do
          expect(doc).to include('origin_info_date_created_tesim' => '1900-04-02')
        end
      end

      context 'when creation date is in parallelEvent' do
        # Select first creation date in first parallelEvent
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title"
              }
            ],
            "event": [
              {
                "type": "creation",
                "parallelEvent": [
                  {
                    "date": [
                      {
                        "value": "1900-04-02",
                        "note": [
                          {
                            "value": "Gregorian",
                            "type": "calendar"
                          }
                        ]
                      }
                    ]
                  },
                  {
                    "date": [
                      {
                        "value": "1900-03-20",
                        "note": [
                          {
                            "value": "Julian",
                            "type": "calendar"
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          JSON
        end

        xit 'populates origin_info_date_created_tesim' do
          expect(doc).to include('origin_info_date_created_tesim' => '1900-04-02')
        end
      end
    end
  end
end
