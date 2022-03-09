# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptiveMetadataIndexer do
  subject(:indexer) { described_class.new(cocina: cocina) }

  let(:cocina) { Cocina::Models.build(JSON.parse(json)) }
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
  let(:doc) { indexer.to_solr }

  describe 'subject mappings from Cocina to Solr sw_subject_temporal_ssim' do
    context 'when single temporal subject' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              value: '14th century',
              type: 'time'
            }
          ]
        }
      end

      it 'selects temporal subject' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century'])
      end
    end

    context 'when multiple temporal subjects' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              value: '14th century',
              type: 'time'
            },
            {
              value: '15th century',
              type: 'time'
            }
          ]
        }
      end

      it 'selects temporal subjects' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century', '15th century'])
      end
    end

    context 'when temporal subject is range' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              structuredValue: [
                {
                  value: '14th century',
                  type: 'start'
                },
                {
                  value: '15th century',
                  type: 'end'
                }
              ],
              type: 'time'
            }
          ]
        }
      end

      it 'selects both temporal subjects in range' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century', '15th century'])
      end
    end

    context 'when temporal subject has encoding' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              value: '1400',
              type: 'time',
              encoding: {
                code: 'w3cdtf'
              }
            }
          ]
        }
      end

      it 'selects temporal subject' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['1400'])
      end
    end

    context 'when temporal subject is part of complex subject' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              structuredValue: [
                {
                  value: 'Europe',
                  type: 'place'
                },
                {
                  value: '14th century',
                  type: 'time'
                }
              ]
            }
          ]
        }
      end

      it 'selects temporal subject from complex subject' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century'])
      end
    end

    context 'when temporal subject range is part of complex subject' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              value: 'Europe',
              type: 'place'
            },
            {
              structuredValue: [
                {
                  value: '14th century',
                  type: 'start'
                },
                {
                  value: '15th century',
                  type: 'end'
                }
              ],
              type: 'time'
            }
          ]
        }
      end

      it 'selects temporal subject range from complex subject' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century', '15th century'])
      end
    end

    context 'when temporal subject in parallelValue' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              parallelValue: [
                {
                  value: '14th century'
                },
                {
                  value: 'XIVieme siecle'
                }
              ],
              type: 'time'
            }
          ]
        }
      end

      it 'selects temporal subjects from parallelValue' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century', 'XIVieme siecle'])
      end
    end

    context 'when temporal subject range in parallelValue' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              parallelValue: [
                {
                  structuredValue: [
                    {
                      value: '14th century',
                      type: 'start'
                    },
                    {
                      value: '15th century',
                      type: 'end'
                    }
                  ]
                },
                {
                  structuredValue: [
                    {
                      value: 'XIVieme siecle',
                      type: 'start'
                    },
                    {
                      value: 'XVieme siecle',
                      type: 'end'
                    }
                  ]
                }
              ],
              type: 'time'
            }
          ]
        }
      end

      it 'selects temporal subject range from parallelValue' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century', '15th century', 'XIVieme siecle', 'XVieme siecle'])
      end
    end

    context 'when complex subject in parallelValue' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              parallelValue: [
                {
                  structuredValue: [
                    {
                      value: 'Europe',
                      type: 'place'
                    },
                    {
                      value: '14th century',
                      type: 'time'
                    }
                  ]
                },
                {
                  structuredValue: [
                    {
                      value: 'Europe',
                      type: 'place'
                    },
                    {
                      value: 'XIVieme siecle',
                      type: 'time'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects temporal subjects from complex subjects' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century', 'XIVieme siecle'])
      end
    end

    context 'when range in complex subject in parallelValue' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              parallelValue: [
                {
                  structuredValue: [
                    {
                      value: 'Europe',
                      type: 'place'
                    },
                    {
                      structuredValue: [
                        {
                          value: '14th century',
                          type: 'start'
                        },
                        {
                          value: '15th century',
                          type: 'end'
                        }
                      ],
                      type: 'time'
                    }
                  ]
                },
                {
                  structuredValue: [
                    {
                      value: 'Europe',
                      type: 'place'
                    },
                    {
                      structuredValue: [
                        {
                          value: 'XIVieme siecle',
                          type: 'start'
                        },
                        {
                          value: 'XVieme siecle',
                          type: 'end'
                        }
                      ],
                      type: 'time'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects temporal range from complex subjects' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century', '15th century', 'XIVieme siecle', 'XVieme siecle'])
      end
    end

    context 'when temporal subject is duplicated across multiple complex subjects' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              structuredValue: [
                {
                  value: 'Europe',
                  type: 'place'
                },
                {
                  value: '14th century',
                  type: 'time'
                }
              ]
            },
            {
              structuredValue: [
                {
                  value: 'Africa',
                  type: 'place'
                },
                {
                  value: '14th century',
                  type: 'time'
                }
              ]
            }
          ]
        }
      end

      it 'drops duplicate value' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century'])
      end
    end

    context 'when temporal subject has trailing punctuation to drop' do
      # punctuation dropped at end of value: backslash, comma, semicolon, along with space
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              value: '14th century,',
              type: 'time'
            }
          ]
        }
      end

      it 'drops punctuation' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century'])
      end
    end

    context 'when temporal subject range has trailing punctuation to drop' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              structuredValue: [
                {
                  value: '14th century;',
                  type: 'start'
                },
                {
                  value: '15th century;',
                  type: 'end'
                }
              ],
              type: 'time'
            }
          ]
        }
      end

      it 'drops punctuation' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century', '15th century'])
      end
    end

    context 'when complex subject has trailing punctuation to drop' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              structuredValue: [
                {
                  value: 'Europe',
                  type: 'place'
                },
                {
                  value: '14th century \\',
                  type: 'time'
                }
              ]
            }
          ]
        }
      end

      it 'drops punctuation' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century'])
      end
    end

    context 'when range in complex subject has trailing punctuation to drop' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              value: 'Europe',
              type: 'place'
            },
            {
              structuredValue: [
                {
                  value: '14th century\\',
                  type: 'start'
                },
                {
                  value: '15th century\\',
                  type: 'end'
                }
              ],
              type: 'time'
            }
          ]
        }
      end

      it 'drops punctuation' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century', '15th century'])
      end
    end

    context 'when temporal subject in parallelValue has trailing punctuation to drop' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              parallelValue: [
                {
                  value: '14th century,'
                },
                {
                  value: 'XIVieme siecle,'
                }
              ],
              type: 'time'
            }
          ]
        }
      end

      it 'drops punctuation' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century', 'XIVieme siecle'])
      end
    end

    context 'when complex subject in parallelValue has trailing punctuation to drop' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              parallelValue: [
                {
                  structuredValue: [
                    {
                      value: 'Europe',
                      type: 'place'
                    },
                    {
                      value: '14th century ;',
                      type: 'time'
                    }
                  ]
                },
                {
                  structuredValue: [
                    {
                      value: 'Europe',
                      type: 'place'
                    },
                    {
                      value: 'XIVieme siecle ;',
                      type: 'time'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'drops punctuation' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century', 'XIVieme siecle'])
      end
    end

    context 'when range in complex subject in parallelValue has trailing punctuation to drop' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              parallelValue: [
                {
                  structuredValue: [
                    {
                      value: 'Europe',
                      type: 'place'
                    },
                    {
                      structuredValue: [
                        {
                          value: '14th century;',
                          type: 'start'
                        },
                        {
                          value: '15th century;',
                          type: 'end'
                        }
                      ],
                      type: 'time'
                    }
                  ]
                },
                {
                  structuredValue: [
                    {
                      value: 'Europe',
                      type: 'place'
                    },
                    {
                      structuredValue: [
                        {
                          value: 'XIVieme siecle;',
                          type: 'start'
                        },
                        {
                          value: 'XVieme siecle;',
                          type: 'end'
                        }
                      ],
                      type: 'time'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'drops punctuation' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century', '15th century', 'XIVieme siecle', 'XVieme siecle'])
      end
    end

    context 'when temporal subject has trailing punctuation not dropped' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          subject: [
            {
              value: '14th century.',
              type: 'time'
            }
          ]
        }
      end

      it 'does not drop punctuation' do
        expect(doc).to include('sw_subject_temporal_ssim' => ['14th century.'])
      end
    end
  end
end
