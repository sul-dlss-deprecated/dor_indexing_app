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

  describe 'publisher mappings from Cocina to Solr originInfo_publisher_tesim' do
    context 'when single event with one publisher' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              contributor: [
                {
                  name: [
                    {
                      value: 'Stanford University Press'
                    }
                  ],
                  role: [
                    {
                      value: 'publisher'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'uses publisher' do
        expect(doc).to include('originInfo_publisher_tesim' => ['Stanford University Press'])
      end
    end

    context 'when single event with multiple publishers' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              contributor: [
                {
                  name: [
                    {
                      value: 'Stanford University Press'
                    }
                  ],
                  role: [
                    {
                      value: 'publisher'
                    }
                  ]
                },
                {
                  name: [
                    {
                      value: 'Highwire Press'
                    }
                  ],
                  role: [
                    {
                      value: 'publisher'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'uses publishers' do
        expect(doc).to include('originInfo_publisher_tesim' => ['Stanford University Press', 'Highwire Press'])
      end
    end

    context 'when multiple events with publishers' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              contributor: [
                {
                  name: [
                    {
                      value: 'Stanford University Press'
                    }
                  ],
                  role: [
                    {
                      value: 'publisher'
                    }
                  ]
                }
              ]
            },
            {
              contributor: [
                {
                  name: [
                    {
                      value: 'Highwire Press'
                    }
                  ],
                  role: [
                    {
                      value: 'publisher'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'uses publishers' do
        expect(doc).to include('originInfo_publisher_tesim' => ['Stanford University Press', 'Highwire Press'])
      end
    end

    context 'when no event contributor with publisher role' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              contributor: [
                {
                  name: [
                    {
                      value: 'Stanford University Press'
                    }
                  ],
                  role: [
                    {
                      value: 'issuing body'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'does not use publisher' do
        expect(doc).not_to include('originInfo_publisher_tesim')
      end
    end

    context 'when publisher role capitalized' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              contributor: [
                {
                  name: [
                    {
                      value: 'Stanford University Press'
                    }
                  ],
                  role: [
                    {
                      value: 'Publisher'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'uses publisher' do
        expect(doc).to include('originInfo_publisher_tesim' => ['Stanford University Press'])
      end
    end

    context 'when publication event with roleless contributor' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              type: 'publication',
              contributor: [
                {
                  name: [
                    {
                      value: 'Stanford University Press'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'does not use publisher' do
        expect(doc).not_to include('originInfo_publisher_tesim')
      end
    end

    context 'when non-publication event with publisher role' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              type: 'production',
              contributor: [
                {
                  name: [
                    {
                      value: 'Stanford University Press'
                    }
                  ],
                  role: [
                    {
                      value: 'publisher'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'uses publisher' do
        expect(doc).to include('originInfo_publisher_tesim' => ['Stanford University Press'])
      end
    end

    context 'when publisher role in events of multiple types' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              type: 'publication',
              contributor: [
                {
                  name: [
                    {
                      value: 'Stanford University Press'
                    }
                  ],
                  role: [
                    {
                      value: 'publisher'
                    }
                  ]
                }
              ]
            },
            {
              type: 'production',
              contributor: [
                {
                  name: [
                    {
                      value: 'Highwire Press'
                    }
                  ],
                  role: [
                    value: 'publisher'
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'uses publishers' do
        expect(doc).to include('originInfo_publisher_tesim' => ['Stanford University Press', 'Highwire Press'])
      end
    end

    context 'when same publisher in multiple events' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              type: 'publication',
              contributor: [
                {
                  name: [
                    {
                      value: 'Stanford University Press'
                    }
                  ],
                  role: [
                    {
                      value: 'publisher'
                    }
                  ]
                }
              ],
              date: [
                {
                  value: '1990'
                }
              ]
            },
            {
              type: 'publication',
              contributor: [
                {
                  name: [
                    {
                      value: 'Stanford University Press'
                    }
                  ],
                  role: [
                    {
                      value: 'publisher'
                    }
                  ]
                }
              ],
              date: [
                {
                  value: '1995'
                }
              ]
            }
          ]
        }
      end

      it 'dedupes' do
        expect(doc).to include('originInfo_publisher_tesim' => ['Stanford University Press'])
      end
    end

    context 'when parallelEvent' do
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
                  contributor: [
                    {
                      name: [
                        {
                          value: 'СФУ',
                          valueLanguage: {
                            code: 'rus',
                            source: {
                              code: 'iso639-2b'
                            },
                            valueScript: {
                              code: 'Cyrl',
                              source: {
                                code: 'iso15924'
                              }
                            }
                          }
                        }
                      ],
                      role: [
                        {
                          value: 'publisher'
                        }
                      ]
                    }
                  ],
                  date: [
                    {
                      value: '1990'
                    }
                  ]
                },
                {
                  contributor: [
                    {
                      name: [
                        {
                          value: 'SFU',
                          valueLanguage: {
                            code: 'eng',
                            source: {
                              code: 'iso639-2b'
                            },
                            valueScript: {
                              code: 'Latn',
                              source: {
                                code: 'iso15924'
                              }
                            }
                          }
                        }
                      ],
                      role: [
                        {
                          value: 'publisher'
                        }
                      ]
                    }
                  ],
                  date: [
                    {
                      value: '1990'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'uses publishers' do
        expect(doc).to include('originInfo_publisher_tesim' => %w[СФУ SFU])
      end
    end

    context 'when parallelValue' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              contributor: [
                {
                  name: [
                    {
                      parallelValue: [
                        {
                          value: 'СФУ',
                          valueLanguage: {
                            code: 'rus',
                            source: {
                              code: 'iso639-2b'
                            },
                            valueScript: {
                              code: 'Cyrl',
                              source: {
                                code: 'iso15924'
                              }
                            }
                          }
                        },
                        {
                          value: 'SFU',
                          valueLanguage: {
                            code: 'eng',
                            source: {
                              code: 'iso639-2b'
                            },
                            valueScript: {
                              code: 'Latn',
                              source: {
                                code: 'iso15924'
                              }
                            }
                          }
                        }
                      ]
                    }
                  ],
                  role: [
                    {
                      value: 'publisher'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'uses publishers' do
        expect(doc).to include('originInfo_publisher_tesim' => %w[СФУ SFU])
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
              contributor: [
                {
                  name: [
                    {
                      structuredValue: [
                        {
                          value: 'Stanford University Press'
                        },
                        {
                          value: 'Internal Division'
                        }
                      ]
                    }
                  ],
                  role: [
                    {
                      value: 'publisher'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'uses publisher' do
        expect(doc).to include('originInfo_publisher_tesim' => ['Stanford University Press. Internal Division'])
      end
    end
  end
end
