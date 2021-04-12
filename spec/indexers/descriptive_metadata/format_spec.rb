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

  describe 'form/genre mappings from Cocina to Solr sw_format_ssim' do
    context 'when dataset' do
      # value "dataset" is case-insensitive
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'dataset',
              type: 'genre'
            }
          ]
        }
      end

      xit 'assigns format based on genre' do
        expect(doc).to include('sw_format_ssim' => ['Dataset'])
      end
    end

    context 'when manuscript' do
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
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on resource type' do
        expect(doc).to include('sw_format_ssim' => ['Archive/Manuscript'])
      end
    end

    context 'when cartographic' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'cartographic',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on resource type' do
        expect(doc).to include('sw_format_ssim' => ['Map'])
      end
    end

    context 'when mixed material' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'mixed material',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on resource type' do
        expect(doc).to include('sw_format_ssim' => ['Archive/Manuscript'])
      end
    end

    context 'when moving image' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'moving image',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on resource type' do
        expect(doc).to include('sw_format_ssim' => ['Video'])
      end
    end

    context 'when notated music' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'notated music',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on resource type' do
        expect(doc).to include('sw_format_ssim' => ['Music score'])
      end
    end

    context 'when software, multimedia' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'software, multimedia',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on resource type' do
        expect(doc).to include('sw_format_ssim' => ['Software/Multimedia'])
      end
    end

    context 'when software, multimedia and cartographic' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'software, multimedia',
              type: 'resource type'
            },
            {
              value: 'cartographic',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on cartographic resource type' do
        expect(doc).to include('sw_format_ssim' => ['Map'])
      end
    end

    context 'when software, multimedia and dataset' do
      # value "dataset" is case-insensitive
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'software, multimedia',
              type: 'resource type'
            },
            {
              value: 'dataset',
              type: 'genre'
            }
          ]
        }
      end

      xit 'assigns format based on dataset genre' do
        expect(doc).to include('sw_format_ssim' => ['Dataset'])
      end
    end

    context 'when sound recording-musical' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'sound recording-musical',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on resource type' do
        expect(doc).to include('sw_format_ssim' => ['Music recording'])
      end
    end

    context 'when sound recording-nonmusical' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'sound recording-nonmusical',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on resource type' do
        expect(doc).to include('sw_format_ssim' => ['Sound recording'])
      end
    end

    context 'when sound recording' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'sound recording',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on resource type' do
        expect(doc).to include('sw_format_ssim' => ['Sound recording'])
      end
    end

    context 'when still image' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'still image',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on resource type' do
        expect(doc).to include('sw_format_ssim' => ['Image'])
      end
    end

    context 'when text and book because monographic issuance' do
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
          ],
          event: [
            {
              note: [
                {
                  value: 'monographic',
                  type: 'issuance'
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on resource type and issuance' do
        expect(doc).to include('sw_format_ssim' => ['Book'])
      end
    end

    context 'when text and book because monographic issuance in parallelEvent' do
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
          ],
          event: [
            {
              parallelEvent: [
                {
                  note: [
                    {
                      value: 'monographic',
                      type: 'issuance'
                    }
                  ]
                },
                {
                  note: [
                    {
                      value: 'Another event'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on resource type and issuance' do
        expect(doc).to include('sw_format_ssim' => ['Book'])
      end
    end

    context 'when text and book because monographic issuance in parallelValue' do
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
          ],
          event: [
            {
              note: [
                {
                  parallelValue: [
                    {
                      value: 'monographic',
                      type: 'issuance'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on resource type and issuance' do
        expect(doc).to include('sw_format_ssim' => ['Book'])
      end
    end

    context 'when text and not book because manuscript' do
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
            },
            {
              value: 'manuscript',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on manuscript resource type' do
        expect(doc).to include('sw_format_ssim' => ['Archive/Manuscript'])
      end
    end

    context 'when text and periodical because continuing issuance' do
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
          ],
          event: [
            {
              note: [
                {
                  value: 'continuing',
                  type: 'issuance'
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on resource type and issuance' do
        expect(doc).to include('sw_format_ssim' => ['Journal/Periodical'])
      end
    end

    context 'when text and periodical because serial issuance' do
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
          ],
          event: [
            {
              note: [
                {
                  value: 'serial',
                  type: 'issuance'
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on resource type and issuance' do
        expect(doc).to include('sw_format_ssim' => ['Journal/Periodical'])
      end
    end

    context 'when text and periodical because frequency' do
      # actual value of frequency does not matter, so long as it is present
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
          ],
          event: [
            {
              note: [
                {
                  value: 'monthly',
                  type: 'frequency'
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on resource type and frequency' do
        expect(doc).to include('sw_format_ssim' => ['Journal/Periodical'])
      end
    end

    context 'when text and periodical because continuing issuance in parallelEvent' do
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
          ],
          event: [
            {
              parallelEvent: [
                {
                  note: [
                    {
                      value: 'continuing',
                      type: 'issuance'
                    }
                  ]
                },
                {
                  note: [
                    {
                      value: 'Another event'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on resource type and issuance' do
        expect(doc).to include('sw_format_ssim' => ['Journal/Periodical'])
      end
    end

    context 'when text and periodical because serial issuance in parallelEvent' do
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
          ],
          event: [
            {
              parallelEvent: [
                {
                  note: [
                    {
                      value: 'serial',
                      type: 'issuance'
                    }
                  ]
                },
                {
                  note: [
                    {
                      value: 'Another event'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on resource type and issuance' do
        expect(doc).to include('sw_format_ssim' => ['Journal/Periodical'])
      end
    end

    context 'when text and periodical because frequency in parallelEvent' do
      # actual value of frequency does not matter, so long as it is present
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
          ],
          event: [
            {
              parallelEvent: [
                {
                  note: [
                    {
                      value: 'monthly',
                      type: 'frequency'
                    }
                  ]
                },
                {
                  note: [
                    {
                      value: 'Another event'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on resource type and frequency' do
        expect(doc).to include('sw_format_ssim' => ['Journal/Periodical'])
      end
    end

    context 'when text and periodical because continuing issuance in parallelValue' do
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
          ],
          event: [
            {
              note: [
                {
                  parallelValue: [
                    {
                      value: 'continuing',
                      type: 'issuance'
                    },
                    {
                      value: 'Another value'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on resource type and issuance' do
        expect(doc).to include('sw_format_ssim' => ['Journal/Periodical'])
      end
    end

    context 'when text and periodical because serial issuance in parallelValue' do
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
          ],
          event: [
            {
              note: [
                {
                  parallelValue: [
                    {
                      value: 'serial',
                      type: 'issuance'
                    },
                    {
                      value: 'Another value'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on resource type and issuance' do
        expect(doc).to include('sw_format_ssim' => ['Journal/Periodical'])
      end
    end

    context 'when text and periodical because frequency in parallelValue' do
      # actual value of frequency does not matter, so long as it is present
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
          ],
          event: [
            {
              note: [
                {
                  parallelValue: [
                    {
                      value: 'monthly',
                      type: 'frequency'
                    },
                    {
                      value: 'Another value'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on resource type and frequency' do
        expect(doc).to include('sw_format_ssim' => ['Journal/Periodical'])
      end
    end

    context 'when text and archived website' do
      # value "archived website" is case-insensitive
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
            },
            {
              value: 'archived website',
              type: 'genre'
            }
          ]
        }
      end

      xit 'assigns format based on resource type and genre' do
        expect(doc).to include('sw_format_ssim' => ['Archived website'])
      end
    end

    context 'when text and book because not anything else' do
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

      xit 'defaults to Book format' do
        expect(doc).to include('sw_format_ssim' => ['Book'])
      end
    end

    context 'when text and book because not anything else with other form present' do
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
            },
            {
              value: 'article',
              type: 'genre'
            }
          ]
        }
      end

      xit 'assigns format based on resource type' do
        expect(doc).to include('sw_format_ssim' => ['Book'])
      end
    end

    context 'when three dimensional object' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'three dimensional object',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on resource type' do
        expect(doc).to include('sw_format_ssim' => ['Object'])
      end
    end

    context 'when multiple formats in combination not otherwise mapped' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'cartographic',
              type: 'resource type'
            },
            {
              value: 'still image',
              type: 'resource type'
            },
            {
              value: 'dataset',
              type: 'genre'
            }
          ]
        }
      end

      xit 'assigns formats based on all resource types and genres' do
        expect(doc).to include('sw_format_ssim' => ['Map, Image, Dataset'])
      end
    end

    context 'when no mapped resource type or genre value' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'dance notation',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'does not assign a format' do
        expect(doc).not_to include('sw_format_ssim')
      end
    end

    context 'when no mapped type' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              value: 'cartographic'
            }
          ]
        }
      end

      xit 'does not assign a format' do
        expect(doc).not_to include('sw_format_ssim')
      end
    end

    context 'when duplicate formats' do
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
              type: 'resource type'
            },
            {
              value: 'mixed material',
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format once' do
        expect(doc).to include('sw_format_ssim' => ['Archive/Manuscript'])
      end
    end

    context 'when parallelValue, shared type' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              parallelValue: [
                {
                  value: 'notated music'
                },
                {
                  value: 'music annotata'
                }
              ],
              type: 'resource type'
            }
          ]
        }
      end

      xit 'assigns format based on mapped resource type' do
        expect(doc).to include('sw_format_ssim' => ['Music score'])
      end
    end

    context 'when parallelValue, type on value' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              parallelValue: [
                {
                  value: 'notated music',
                  type: 'resource type'
                },
                {
                  value: 'music annotata'
                }
              ]
            }
          ]
        }
      end

      xit 'assigns format based on mapped resource type' do
        expect(doc).to include('sw_format_ssim' => ['Music score'])
      end
    end

    context 'when groupedValue' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          form: [
            {
              groupedValue: [
                {
                  value: 'audio recording',
                  type: 'form'
                },
                {
                  value: '1 audiocassette',
                  type: 'extent'
                },
                {
                  value: 'sound recording',
                  type: 'resource type'
                }
              ]
            },
            {
              groupedValue: [
                {
                  value: 'transcript',
                  type: 'form'
                },
                {
                  value: '5 pages',
                  type: 'extent'
                },
                {
                  value: 'text',
                  type: 'resource type'
                }
              ]
            }
          ]
        }
      end

      xit 'assigns formats based on resource types' do
        expect(doc).to include('sw_format_ssim' => ['Sound recording', 'Book'])
      end
    end
  end
end
