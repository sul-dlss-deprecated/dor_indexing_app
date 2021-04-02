# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptiveMetadataIndexer do
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

        it 'populates origin_info_date_created_tesim' do
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

        it 'populates origin_info_date_created_tesim' do
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

        it 'populates origin_info_date_created_tesim' do
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

        it 'populates origin_info_date_created_tesim' do
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

        it 'populates origin_info_date_created_tesim' do
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

        it 'populates origin_info_date_created_tesim' do
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

        it 'populates origin_info_date_created_tesim' do
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
                    ]
                    "type": "creation",
                    "status": "primary"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates origin_info_date_created_tesim' do
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

        it 'populates origin_info_date_created_tesim' do
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

        it 'populates origin_info_date_created_tesim' do
          expect(doc).to include('origin_info_date_created_tesim' => '1900-04-02')
        end
      end
    end
  end
end
