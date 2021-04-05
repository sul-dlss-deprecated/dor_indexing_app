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

  describe 'title mappings from Cocina to Solr sw_display_title_tesim' do
    describe 'single untyped title' do
      # Select value; status: primary may or may not be present
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ]
        }
      end

      xit 'uses title value' do
        expect(doc).to include('sw_display_title_tesim' => 'Title')
      end
    end

    describe 'single typed title' do
      # Select value; status: primary may or may not be present
      let(:description) do
        {
          title: [
            {
              value: 'Title',
              type: 'translated'
            }
          ]
        }
      end

      xit 'uses title value' do
        expect(doc).to include('sw_display_title_tesim' => 'Title')
      end
    end

    describe 'multiple untyped titles, one primary' do
      # Select primary
      let(:description) do
        {
          title: [
            {
              value: 'Title 1',
              status: 'primary'
            },
            {
              value: 'Title 2'
            }
          ]
        }
      end

      xit 'uses value from title with status primary' do
        expect(doc).to include('sw_display_title_tesim' => 'Title 1')
      end
    end

    describe 'multiple untyped titles, none primary' do
      # Select first
      let(:description) do
        {
          title: [
            {
              value: 'Title 1'
            },
            {
              value: 'Title 2'
            }
          ]
        }
      end

      xit 'uses first value' do
        expect(doc).to include('sw_display_title_tesim' => 'Title 1')
      end
    end

    describe 'multiple typed and untyped titles, one primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title 1',
              type: 'translated',
              status: 'primary'
            },
            {
              value: 'Title 2'
            }
          ]
        }
      end

      xit 'uses value from title with status primary' do
        expect(doc).to include('sw_display_title_tesim' => 'Title 1')
      end
    end

    describe 'multiple typed and untyped titles, none primary' do
      # Select first without type
      let(:description) do
        {
          title: [
            {
              value: 'Title 1',
              type: 'alternative'
            },
            {
              value: 'Title 2'
            },
            {
              value: 'Title 3'
            }
          ]
        }
      end

      xit 'uses value from first title without type' do
        expect(doc).to include('sw_display_title_tesim' => 'Title 2')
      end
    end

    describe 'multiple typed titles, one primary' do
      # Select primary
      let(:description) do
        {
          title: [
            {
              value: 'Title 1',
              type: 'translated',
              status: 'primary'
            },
            {
              value: 'Title 2',
              type: 'alternative'
            }
          ]
        }
      end

      xit 'uses value from title with status primary' do
        expect(doc).to include('sw_display_title_tesim' => 'Title 1')
      end
    end

    describe 'multiple typed titles, none primary' do
      # Select first
      let(:description) do
        {
          title: [
            {
              value: 'Title 1',
              type: 'translated'
            },
            {
              value: 'Title 2',
              type: 'alternative'
            }
          ]
        }
      end

      xit 'uses value from first title' do
        expect(doc).to include('sw_display_title_tesim' => 'Title 1')
      end
    end

    describe 'nonsorting character count' do
      # Note doesn't matter for display value
      let(:description) do
        {
          title: [
            {
              value: 'A title',
              note: [
                {
                  type: 'nonsorting character count',
                  value: '2'
                }
              ]
            }
          ]
        }
      end

      xit 'uses full value from title' do
        expect(doc).to include('sw_display_title_tesim' => 'A title')
      end
    end

    describe 'parallelValue with primary on value' do
      # Select primary
      let(:description) do
        {
          title: [
            {
              parallelValue: [
                {
                  value: 'Title 1',
                  status: 'primary'
                },
                {
                  value: 'Title 2'
                }
              ]
            }
          ]
        }
      end

      xit 'uses value with status primary' do
        expect(doc).to include('sw_display_title_tesim' => 'Title 1')
      end
    end

    describe 'parallelValue with primary on parallelValue' do
      # Select first value in primary parallelValue
      let(:description) do
        {
          title: [
            {
              parallelValue: [
                {
                  value: 'Title 1'
                },
                {
                  value: 'Title 2'
                }
              ],
              status: 'primary'
            }
          ]
        }
      end

      xit 'uses first value from parallelValue with status primary' do
        expect(doc).to include('sw_display_title_tesim' => 'Title 1')
      end
    end

    describe 'parallelValue with primary on value and parallelValue' do
      # Select primary value in primary parallelValue
      let(:description) do
        {
          title: [
            {
              parallelValue: [
                {
                  value: 'Title 1',
                  status: 'primary'
                },
                {
                  value: 'Title 2'
                }
              ],
              status: 'primary'
            }
          ]
        }
      end

      xit 'uses value with status primary in parallelValue' do
        expect(doc).to include('sw_display_title_tesim' => 'Title 1')
      end
    end

    describe 'primary on both parallelValue value and other value' do
      # Select other value with primary; parallelValue primary value is primary within
      # parallelValue but the parallelValue is not itself the primary title
      let(:description) do
        {
          title: [
            {
              parallelValue: [
                {
                  value: 'Title 1',
                  status: 'primary'
                },
                {
                  value: 'Title 2'
                }
              ]
            },
            {
              value: 'Title 3',
              status: 'primary'
            }
          ]
        }
      end

      xit 'uses value from outermost title with status primary' do
        expect(doc).to include('sw_display_title_tesim' => 'Title 3')
      end
    end

    describe 'parallelValue with additional value, parallelValue first, no primary' do
      # Select first value, in this case inside parallelValue
      let(:description) do
        {
          title: [
            {
              parallelValue: [
                {
                  value: 'Title 1'
                },
                {
                  value: 'Title 2'
                }
              ]
            },
            {
              value: 'Title 3'
            }
          ]
        }
      end

      xit 'uses first value' do
        expect(doc).to include('sw_display_title_tesim' => 'Title 1')
      end
    end

    describe 'parallelValue with additional value, value first, no primary' do
      # Select first value
      let(:description) do
        {
          title: [
            {
              value: 'Title 3'
            },
            {
              parallelValue: [
                {
                  value: 'Title 1'
                },
                {
                  value: 'Title 2'
                }
              ]
            }
          ]
        }
      end

      xit 'uses first value' do
        expect(doc).to include('sw_display_title_tesim' => 'Title 3')
      end
    end

    # **** Constructing title from structuredValue ****

    # nonsorting characters value is followed by a space, unless the nonsorting
    #   character count note has a numeric value equal to the length of the
    #   nonsorting characters value, in which case no space is inserted
    # subtitle is preceded by space colon space, unless it is at the beginning
    #   of the title string
    # partName and partNumber are always separated from each other by comma space
    # first partName or partNumber in the string is preceded by period space
    # partName or partNumber before nonsorting characters or main title is followed
    #   by period space
    describe 'structuredValue with all parts in common order' do
      let(:description) do
        {
          title: [
            {
              structuredValue: [
                {
                  value: 'A',
                  type: 'nonsorting characters'
                },
                {
                  value: 'title',
                  type: 'main title'
                },
                {
                  value: 'a subtitle',
                  type: 'subtitle'
                },
                {
                  value: 'Vol. 1',
                  type: 'part number'
                },
                {
                  value: 'Supplement',
                  type: 'part name'
                }
              ]
            }
          ]
        }
      end

      xit 'constructs title from structuredValue' do
        expect(doc).to include('sw_display_title_tesim' => 'A title : a subtitle. Vol. 1, Supplement')
      end
    end

    describe 'structuredValue with parts in uncommon order' do
      # improvement on stanford_mods in that it respects field order as given
      # based on ckey 9803970
      let(:description) do
        {
          title: [
            {
              structuredValue: [
                {
                  value: 'The',
                  type: 'nonsorting characters'
                },
                {
                  value: 'title',
                  type: 'main title'
                },
                {
                  value: 'Vol. 1',
                  type: 'part number'
                },
                {
                  value: 'Supplement',
                  type: 'part name'
                },
                {
                  value: 'a subtitle',
                  type: 'subtitle'
                }
              ]
            }
          ]
        }
      end

      xit 'constructs title from structuredValue, respecting order of occurrence' do
        expect(doc).to include('sw_display_title_tesim' => 'The title. Vol. 1, Supplement : a subtitle')
      end
    end

    describe 'structuredValue with multiple partName and partNumber' do
      # improvement on stanford_mods in that it respects field order as given
      let(:description) do
        {
          title: [
            {
              structuredValue: [
                {
                  value: 'Title',
                  type: 'main title'
                },
                {
                  value: 'Special series',
                  type: 'part name'
                },
                {
                  value: 'Vol. 1',
                  type: 'part number'
                },
                {
                  value: 'Supplement',
                  type: 'part name'
                }
              ]
            }
          ]
        }
      end

      xit 'constructs title from structuredValue, respecting order of occurrence' do
        expect(doc).to include('sw_display_title_tesim' => 'Title. Special series, Vol. 1, Supplement')
      end
    end

    describe 'structuredValue with part before title' do
      # improvement on stanford_mods in that it respects field order as given
      let(:description) do
        {
          title: [
            {
              structuredValue: [
                {
                  value: 'Series 1',
                  type: 'part number'
                },
                {
                  value: 'Title',
                  type: 'main title'
                }
              ]
            }
          ]
        }
      end

      xit 'constructs title from structuredValue, respecting order of occurrence' do
        expect(doc).to include('sw_display_title_tesim' => 'Series 1. Title')
      end
    end

    describe 'structuredValue with nonsorting character count' do
      # improvement on stanford_mods in that it does not force a space separator
      let(:description) do
        {
          title: [
            {
              structuredValue: [
                {
                  value: "L'",
                  type: 'nonsorting characters'
                },
                {
                  value: 'autre title',
                  type: 'main title'
                }
              ],
              note: [
                {
                  value: '2',
                  type: 'nonsorting character count'
                }
              ]
            }
          ]
        }
      end

      xit 'constructs title from structuredValue, respecting order of occurrence' do
        expect(doc).to include('sw_display_title_tesim' => 'L\'autre title')
      end
    end

    describe 'structuredValue for uniform title' do
      # Omit author name when uniform title is preferred title for display
      let(:description) do
        {
          title: [
            {
              structuredValue: [
                {
                  value: 'Author, An',
                  type: 'name'
                },
                {
                  value: 'Title',
                  type: 'Title'
                }
              ],
              type: 'uniform'
            }
          ]
        }
      end

      xit 'constructs title from structuredValue without author name' do
        expect(doc).to include('sw_display_title_tesim' => 'Title')
      end
    end

    # Handling punctuation

    describe 'punctuation/space in simple value' do
      # strip one or more instances of .,;:/\ plus whitespace at beginning or end of string

      let(:description) do
        {
          title: [
            {
              value: 'Title /'
            }
          ]
        }
      end

      xit 'uses value with trailing punctuation of .,;:/\ stripped' do
        expect(doc).to include('sw_display_title_tesim' => 'Title')
      end
    end

    describe 'punctuation/space in structuredValue' do
      # strip one or more instances of .,;:/\ plus whitespace at beginning or end of string
      let(:description) do
        {
          title: [
            {
              structuredValue: [
                {
                  value: 'Title.',
                  type: 'main title'
                },
                {
                  value: ':subtitle',
                  type: 'subtitle'
                }
              ]
            }
          ]
        }
      end

      xit 'uses value with trailing punctuation of .,;:/\ stripped' do
        expect(doc).to include('sw_display_title_tesim' => 'Title : subtitle')
      end
    end
  end
end
