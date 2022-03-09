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

  describe 'primary contributor mappings from Cocina to Solr sw_author_tesim' do
    ### Select contributor
    context 'when single contributor' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              name: [
                {
                  value: 'Sayers, Dorothy L.'
                }
              ]
            }
          ]
        }
      end

      it 'selects name of contributor' do
        expect(doc).to include('sw_author_tesim' => 'Sayers, Dorothy L.')
      end
    end

    context 'when multiple contributors, one with primary status' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              name: [
                {
                  value: 'Sayers, Dorothy L.'
                }
              ],
              status: 'primary'
            },
            {
              name: [
                {
                  value: 'Dunnett, Dorothy'
                }
              ]
            }
          ]
        }
      end

      it 'selects name of contributor with primary status' do
        expect(doc).to include('sw_author_tesim' => 'Sayers, Dorothy L.')
      end
    end

    context 'when multiple contributors, none with primary status' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              name: [
                {
                  value: 'Sayers, Dorothy L.'
                }
              ]
            },
            {
              name: [
                {
                  value: 'Dunnett, Dorothy'
                }
              ]
            }
          ]
        }
      end

      it 'selects name of first contributor' do
        expect(doc).to include('sw_author_tesim' => 'Sayers, Dorothy L.')
      end
    end

    ### Select name

    context 'when selected contributor has display name' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              name: [
                {
                  value: 'Sayers, Dorothy L. (Dorothy Leigh), 1893-1957'
                },
                {
                  value: 'Sayers, Dorothy L.',
                  type: 'display'
                }
              ]
            }
          ]
        }
      end

      it 'selects display name of contributor' do
        expect(doc).to include('sw_author_tesim' => 'Sayers, Dorothy L.')
      end
    end

    context 'when selected contributor has multiple names, one primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              name: [
                {
                  value: 'Sayers, Dorothy L.',
                  status: 'primary'
                },
                {
                  value: 'Sayers, Dorothy L. (Dorothy Leigh), 1893-1957'
                }
              ]
            }
          ]
        }
      end

      it 'selects primary name of contributor' do
        expect(doc).to include('sw_author_tesim' => 'Sayers, Dorothy L.')
      end
    end

    context 'when selected contributor has multiple names, none primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              name: [
                {
                  value: 'Sayers, Dorothy L.'
                },
                {
                  value: 'Sayers, Dorothy L. (Dorothy Leigh), 1893-1957'
                }
              ]
            }
          ]
        }
      end

      it 'selects first name of contributor' do
        expect(doc).to include('sw_author_tesim' => 'Sayers, Dorothy L.')
      end
    end

    context 'when selected contributor has parallelContributor, one primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              parallelContributor: [
                {
                  name: [
                    {
                      value: 'Zhou, L.-F. (Liang-Fu)',
                      status: 'primary'
                    }
                  ],
                  role: [
                    {
                      value: 'zeng bu'
                    }
                  ]
                },
                {
                  name: [
                    {
                      value: '周亮輔'
                    }
                  ],
                  role: [
                    {
                      value: '增補'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects primary name from parallelContributor' do
        expect(doc).to include('sw_author_tesim' => 'Zhou, L.-F. (Liang-Fu)')
      end
    end

    context 'when selected contributor has parallelContributor, no primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              parallelContributor: [
                {
                  name: [
                    {
                      value: 'Zhou, L.-F. (Liang-Fu)'
                    }
                  ],
                  role: [
                    {
                      value: 'zeng bu'
                    }
                  ]
                },
                {
                  name: [
                    {
                      value: '周亮輔'
                    }
                  ],
                  role: [
                    {
                      value: '增補'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects first name from parallelContributor' do
        expect(doc).to include('sw_author_tesim' => 'Zhou, L.-F. (Liang-Fu)')
      end
    end

    context 'when selected name has parallelValue, one primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              name: [
                {
                  parallelValue: [
                    {
                      value: 'Булгаков, Михаил Афанасьевич'
                    },
                    {
                      value: 'Bulgakov, Mikhail Afanasʹevich',
                      status: 'primary'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects primary name from parallelValue' do
        expect(doc).to include('sw_author_tesim' => 'Bulgakov, Mikhail Afanasʹevich')
      end
    end

    context 'when selected name has parallelValue, no primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              name: [
                {
                  parallelValue: [
                    {
                      value: 'Булгаков, Михаил Афанасьевич'
                    },
                    {
                      value: 'Bulgakov, Mikhail Afanasʹevich'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects first name from parallelValue' do
        expect(doc).to include('sw_author_tesim' => 'Булгаков, Михаил Афанасьевич')
      end
    end

    context 'when selected name has groupedValue' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              name: [
                {
                  groupedValue: [
                    {
                      value: 'Strachey, Dorothy',
                      type: 'name'
                    },
                    {
                      value: 'Olivia',
                      type: 'pseudonym'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects value with type name' do
        expect(doc).to include('sw_author_tesim' => 'Strachey, Dorothy')
      end
    end

    ### Construct name

    context 'when selected name has structuredValue with name parts' do
      # Concatenate all with type surname in order provided, space delimeter
      # Concatenate all with type forename in order provided, space delimiter
      # Concatenate all with type term of address in order provided, comma space delimiter
      # Concatenate combined surname with combined forename, comma space delimiter
      # Append combined term of address, space delimiter
      # Append life or activity dates, comma space delimiter
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              name: [
                {
                  structuredValue: [
                    {
                      value: 'Dorothy',
                      type: 'forename'
                    },
                    {
                      value: 'Leigh',
                      type: 'forename'
                    },
                    {
                      value: 'Sayers',
                      type: 'surname'
                    },
                    {
                      value: 'Fleming',
                      type: 'surname'
                    },
                    {
                      value: 'B.A. (Oxon.)',
                      type: 'term of address'
                    },
                    {
                      value: 'M.A. (Oxon.)',
                      type: 'term of address'
                    },
                    {
                      value: '1893-1957',
                      type: 'life dates'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'constructs name of contributor' do
        # No comma between name and term of address because also used for e.g. Elizabeth I
        expect(doc).to include('sw_author_tesim' => 'Sayers Fleming, Dorothy Leigh B.A. (Oxon.), M.A. (Oxon.), 1893-1957')
      end
    end

    context 'when selected name has structuredValue with full name' do
      # Concatenate all with type term of address in order provided, comma space delimiter
      # Append combined term of address to name, space delimiter
      # Append life or activity dates, comma space delimiter
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              name: [
                {
                  structuredValue: [
                    {
                      value: 'Sayers, Dorothy L.',
                      type: 'name'
                    },
                    {
                      value: 'B.A. (Oxon.)',
                      type: 'term of address'
                    },
                    {
                      value: 'M.A. (Oxon.)',
                      type: 'term of address'
                    },
                    {
                      value: '1893-1957',
                      type: 'life dates'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'constructs name of contributor' do
        # No comma between name and term of address because also used for e.g. Elizabeth I
        expect(doc).to include('sw_author_tesim' => 'Sayers, Dorothy L. B.A. (Oxon.), M.A. (Oxon.), 1893-1957')
      end
    end

    context 'when selected name has structuredValue with multiple parts with name type' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          contributor: [
            {
              name: [
                {
                  structuredValue: [
                    {
                      value: 'United States',
                      type: 'name'
                    },
                    {
                      value: 'Office of Foreign Investment in the United States',
                      type: 'name'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'constructs name of contributor' do
        # Concatenate in order given, period space delimiter
        expect(doc).to include('sw_author_tesim' => 'United States. Office of Foreign Investment in the United States')
      end
    end
  end
end
