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

  describe 'subject mappings from Cocina to Solr sw_subject_geographic_ssim' do
    context 'when single geographic subject' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              value: 'Europe',
              type: 'place'
            }
          ]
        }
      end

      it 'selects geographic subject' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['Europe'])
      end
    end

    context 'when multiple geographic subjects' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              value: 'Europe',
              type: 'place'
            },
            {
              value: 'Africa',
              type: 'place'
            }
          ]
        }
      end

      it 'selects geographic subjects' do
        expect(doc).to include('sw_subject_geographic_ssim' => %w[Europe Africa])
      end
    end

    context 'when part of complex subject' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              structuredValue: [
                {
                  value: 'Art',
                  type: 'topic'
                },
                {
                  value: 'Europe',
                  type: 'place'
                }
              ]
            }
          ]
        }
      end

      it 'selects geographic subject from complex subject' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['Europe'])
      end
    end

    context 'when in parallelValue' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              parallelValue: [
                {
                  value: 'Russia'
                },
                {
                  value: 'Россия'
                }
              ],
              type: 'place'
            }
          ]
        }
      end

      it 'selects geographic subjects from parallelValue' do
        expect(doc).to include('sw_subject_geographic_ssim' => %w[Russia Россия])
      end
    end

    context 'when part of complex subject in parallelValue' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              parallelValue: [
                {
                  structuredValue: [
                    {
                      value: 'Art',
                      type: 'topic'
                    },
                    {
                      value: 'Russia',
                      type: 'place'
                    }
                  ]
                },
                {
                  structuredValue: [
                    {
                      value: 'Изобразительное искусство',
                      type: 'topic'
                    },
                    {
                      value: 'Россия',
                      type: 'place'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects geographic subject from complex subject' do
        expect(doc).to include('sw_subject_geographic_ssim' => %w[Russia Россия])
      end
    end

    context 'when same value in multiple complex subjects' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
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
                  value: 'Europe',
                  type: 'place'
                },
                {
                  value: '15th century',
                  type: 'time'
                }
              ]
            }
          ]
        }
      end

      it 'dedupes the value' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['Europe'])
      end
    end

    context 'when code value from mapped authority - marcgac' do
      # mapped authorities are marcgac and marccountry
      # marcgac mapping: https://github.com/sul-dlss/mods/blob/master/lib/mods/marc_geo_area_codes.rb
      # marccountry mapping: https://github.com/sul-dlss/stanford-mods/blob/master/lib/marc_countries.rb
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              code: 'e-ru',
              type: 'place',
              source: {
                code: 'marcgac'
              }
            }
          ]
        }
      end

      it 'maps the code to text' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['Russia (Federation)'])
      end
    end

    context 'when code value from mapped authority - marccountry' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              code: 'ru',
              type: 'place',
              source: {
                code: 'marccountry'
              }
            }
          ]
        }
      end

      it 'maps the code to text' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['Russia (Federation)'])
      end
    end

    context 'when code value from unmapped authority' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              code: 'aahgr',
              type: 'place',
              source: {
                code: 'ccga'
              }
            }
          ]
        }
      end

      it 'ignores the code' do
        expect(doc).not_to include('sw_subject_geographic_ssim')
      end
    end

    context 'when code has no authority' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              code: 'aahgr',
              type: 'place'
            }
          ]
        }
      end

      it 'ignores the code' do
        expect(doc).not_to include('sw_subject_geographic_ssim')
      end
    end

    context 'when text with code matches mapped text' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              value: 'Russia (Federation)',
              code: 'ru',
              type: 'place',
              source: {
                code: 'marccountry'
              }
            }
          ]
        }
      end

      it 'includes term once' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['Russia (Federation)'])
      end
    end

    context 'when text with code does not match mapped text' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              value: 'Russia',
              code: 'ru',
              type: 'place',
              source: {
                code: 'marccountry'
              }
            }
          ]
        }
      end

      it 'includes both terms' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['Russia', 'Russia (Federation)'])
      end
    end

    context 'when hierarchical geographic subject' do
      # separator is space
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              structuredValue: [
                {
                  value: 'North America',
                  type: 'continent'
                },
                {
                  value: 'Canada',
                  type: 'country'
                },
                {
                  value: 'Vancouver',
                  type: 'city'
                }
              ],
              type: 'place'
            }
          ]
        }
      end

      it 'constructs the value' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['North America Canada Vancouver'])
      end
    end

    context 'when terminal punctuation should be dropped from value' do
      # punctuation to drop: comma, backslash, semicolon, plus any whitespace
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              value: 'Europe,',
              type: 'place'
            }
          ]
        }
      end

      it 'drops the punctuation' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['Europe'])
      end
    end

    context 'when terminal punctuation should be dropped from complex subject' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              structuredValue: [
                {
                  value: 'Art',
                  type: 'topic'
                },
                {
                  value: 'Europe \\',
                  type: 'place'
                }
              ]
            }
          ]
        }
      end

      it 'drops the punctuation' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['Europe'])
      end
    end

    context 'when terminal punctuation should be dropped from parallelValue' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              parallelValue: [
                {
                  value: 'Russia;'
                },
                {
                  value: 'Россия;'
                }
              ],
              type: 'place'
            }
          ]
        }
      end

      it 'drops the punctuation' do
        expect(doc).to include('sw_subject_geographic_ssim' => %w[Russia Россия])
      end
    end

    context 'when terminal punctuation should be dropped from complex subject in parallelValue' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              parallelValue: [
                {
                  structuredValue: [
                    {
                      value: 'Art',
                      type: 'topic'
                    },
                    {
                      value: 'Russia;',
                      type: 'place'
                    }
                  ]
                },
                {
                  structuredValue: [
                    {
                      value: 'Изобразительное искусство',
                      type: 'topic'
                    },
                    {
                      value: 'Россия,',
                      type: 'place'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'drops the punctuation' do
        expect(doc).to include('sw_subject_geographic_ssim' => %w[Russia Россия])
      end
    end

    context 'when terminal punctuation should not be dropped' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              value: 'Europe.',
              type: 'place'
            }
          ]
        }
      end

      it 'does not drop the punctuation' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['Europe.'])
      end
    end

    context 'when duplicate terms with different terminal punctuation that should be dropped' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              value: 'Europe;',
              type: 'place'
            },
            {
              value: 'Europe',
              type: 'place'
            }
          ]
        }
      end

      it 'drops the punctuation before deduping' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['Europe'])
      end
    end

    context 'when terminal punctuation should be dropped from code' do
      let(:description) do
        {
          title: [
            {
              value: 'title'
            }
          ],
          subject: [
            {
              code: 'e-ru;',
              type: 'place',
              source: {
                code: 'marcgac'
              }
            }
          ]
        }
      end

      it 'drops the punctuation' do
        expect(doc).to include('sw_subject_geographic_ssim' => ['Russia (Federation)'])
      end
    end
  end
end
