# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptiveMetadataIndexer do
  subject(:indexer) { described_class.new(cocina: cocina) }

  let(:cocina) { Cocina::Models.build(JSON.parse(json)) }
  let(:doc) { indexer.to_solr }
  let(:json) do
    <<~JSON
      {
        "cocinaVersion": "0.0.1",
        "type": "#{Cocina::Models::ObjectType.image}",
        "externalIdentifier": "druid:qy781dy0220",
        "label": "SUL Logo for forebrain",
        "version": 1,
        "access": {
          "view": "world",
          "copyright": "This work is copyrighted by the creator.",
          "download": "world",
          "useAndReproductionStatement": "This document is available only to the Stanford faculty, staff and student community."
        },
        "administrative": {
          "hasAdminPolicy": "druid:zx485kb6348"
        },
        "description": #{JSON.generate(description.merge(purl: 'https://purl.stanford.edu/qy781dy0220'))},
        "identification": {
          "sourceId": "hydrus:object-6"
        },
        "structural": {
          "contains": [{
            "type": "#{Cocina::Models::FileSetType.file}",
            "externalIdentifier": "qy781dy0220_1",
            "label": "qy781dy0220_1",
            "version": 1,
            "structural": {
              "contains": [{
                "type": "#{Cocina::Models::ObjectType.file}",
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
                  "view": "world",
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

  describe 'place mappings from Cocina to Solr originInfo_place_placeTerm_tesim' do
    # Constructs single place value from a selected event
    # marccountry code mapping: https://github.com/sul-dlss/stanford-mods/blob/master/lib/marc_countries.rb
    context 'when single place text value' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  value: 'Stanford (Calif.)'
                }
              ]
            }
          ]
        }
      end

      it 'selects one place text value' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'Stanford (Calif.)')
      end
    end

    context 'when multiple place text values, none primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  value: 'Stanford (Calif.)'
                },
                {
                  value: 'United States'
                }
              ]
            }
          ]
        }
      end

      it 'selects all place text values and concatenates with space colon space' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'Stanford (Calif.) : United States')
      end
    end

    context 'when multiple place text values, one primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  value: 'Stanford (Calif.)',
                  status: 'primary'
                },
                {
                  value: 'United States'
                }
              ]
            }
          ]
        }
      end

      it 'selects primary place text value' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'Stanford (Calif.)')
      end
    end

    context 'when place code with marccountry authority' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  code: 'cau',
                  source: {
                    code: 'marccountry'
                  }
                }
              ]
            }
          ]
        }
      end

      it 'selects marccountry place code and maps to text value' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'California')
      end
    end

    context 'when place code with marccountry authorityURI' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  code: 'cau',
                  source: {
                    uri: 'http://id.loc.gov/vocabulary/countries/'
                  }
                }
              ]
            }
          ]
        }
      end

      it 'selects marccountry place code and maps to text value' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'California')
      end
    end

    context 'when place code with marccountry valueURI' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  uri: 'http://id.loc.gov/vocabulary/countries/cau'
                }
              ]
            }
          ]
        }
      end

      it 'selects marccountry place code and maps to text value' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'California')
      end
    end

    context 'when place code with non-marccountry authority' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  code: 'n-us-ca',
                  source: {
                    code: 'marcgac'
                  }
                }
              ]
            }
          ]
        }
      end

      it 'does not select a place' do
        expect(doc).not_to include('originInfo_place_placeTerm_tesim')
      end
    end

    context 'when text and marccountry code in same location' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  value: 'California',
                  code: 'cau',
                  source: {
                    code: 'marccountry'
                  }
                }
              ]
            }
          ]
        }
      end

      it 'selects the place text value' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'California')
      end
    end

    context 'when text and marccountry code in different locations' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  value: 'Stanford (Calif.)'
                },
                {
                  code: 'cau',
                  source: {
                    code: 'marccountry'
                  }
                }
              ]
            }
          ]
        }
      end

      it 'selects the place text value and omits the code' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'Stanford (Calif.)')
      end
    end

    context 'when place text and non-marccountry code' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  value: 'California',
                  code: 'n-us-ca',
                  source: {
                    code: 'marcgac'
                  }
                }
              ]
            }
          ]
        }
      end

      it 'selects the place text value' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'California')
      end
    end

    context 'when parallelEvent, none primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              parallelEvent: [
                {
                  location: [
                    {
                      value: 'Moscow'
                    }
                  ]
                },
                {
                  location: [
                    {
                      value: 'Москва'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects all values and concatenates with space colon space' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'Moscow : Москва')
      end
    end

    context 'when parallelEvent, one primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              parallelEvent: [
                {
                  location: [
                    {
                      value: 'Moscow'
                    }
                  ]
                },
                {
                  location: [
                    {
                      value: 'Москва',
                      status: 'primary'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects primary value' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'Москва')
      end
    end

    context 'when parallelValue, none primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  parallelValue: [
                    {
                      value: 'Moscow'
                    },
                    {
                      value: 'Москва'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects all values and concatenates with space colon space' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'Moscow : Москва')
      end
    end

    context 'when parallelValue, one primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  parallelValue: [
                    {
                      value: 'Moscow',
                      status: 'primary'
                    },
                    {
                      value: 'Москва'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects primary value' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'Moscow')
      end
    end

    context 'when structuredValue' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              location: [
                {
                  structuredValue: [
                    {
                      value: 'Stanford'
                    },
                    {
                      value: 'California'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'concatenates structured value with space colon space' do
        expect(doc).to include('originInfo_place_placeTerm_tesim' => 'Stanford : California')
      end
    end
  end
end
