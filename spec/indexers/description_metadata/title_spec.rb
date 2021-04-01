# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescribableIndexer do
  describe 'title mappings from Cocina to Solr' do
    describe 'single untyped title' do
      # Select value; status: primary may or may not be present
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title')
        end
      end
    end

    describe 'single typed title' do
      # Select value; status: primary may or may not be present
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title",
                "type": "translated"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title')
        end
      end
    end

    describe 'multiple untyped titles, one primary' do
      # Select primary
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title 1",
                "status": "primary"
              },
              {
                "value": "Title 2"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title 1')
        end
      end
    end

    describe 'multiple untyped titles, none primary' do
      # Select first
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title 1"
              },
              {
                "value": "Title 2"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title 1')
        end
      end
    end

    describe 'multiple typed and untyped titles, one primary' do
      # Select primary
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title 1",
                "type": "translated",
                "status": "primary"
              },
              {
                "value": "Title 2"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title 1')
        end
      end
    end

    describe 'multiple typed and untyped titles, none primary' do
      # Select first without type
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title 1",
                "type": "alternative"
              },
              {
                "value": "Title 2"
              },
              {
                "value": "Title 3"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title 2')
        end
      end
    end

    describe 'multiple typed titles, one primary' do
      # Select primary
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title 1",
                "type": "translated",
                "status": "primary"
              },
              {
                "value": "Title 2",
                "type": "alternative"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title 1')
        end
      end
    end

    describe 'multiple typed titles, none primary' do
      # Select first
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title 1",
                "type": "translated"
              },
              {
                "value": "Title 2",
                "type": "alternative"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title 1')
        end
      end
    end

    describe 'nonsorting character count' do
      # Note doesn't matter for display value
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "A title",
                "note": [
                  {
                    "type": "nonsorting character count",
                    "value": "2"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'A title')
        end
      end
    end

    describe 'parallelValue with primary on value' do
      # Select primary
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "parallelValue": [
                  {
                    "value": "Title 1"
                    "status": "primary"
                  },
                  {
                    "value": "Title 2"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title 1')
        end
      end
    end

    describe 'parallelValue with primary on parallelValue' do
      # Select first value in primary parallelValue
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "parallelValue": [
                  {
                    "value": "Title 1"
                  },
                  {
                    "value": "Title 2"
                  }
                ],
                "status": "primary"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title 1')
        end
      end
    end

    describe 'parallelValue with primary on value and parallelValue' do
      # Select primary value in primary parallelValue
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "parallelValue": [
                  {
                    "value": "Title 1",
                    "status": "primary"
                  },
                  {
                    "value": "Title 2"
                  }
                ],
                "status": "primary"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title 1')
        end
      end
    end

    describe 'primary on both parallelValue value and other value' do
      # Select other value with primary; parallelValue primary value is primary within
      # parallelValue but the parallelValue is not itself the primary title
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "parallelValue": [
                  {
                    "value": "Title 1",
                    "status": "primary"
                  },
                  {
                    "value": "Title 2"
                  }
                ]
              },
              {
                "value": "Title 3",
                "status": "primary"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title 3')
        end
      end
    end

    describe 'parallelValue with additional value, parallelValue first, no primary' do
      # Select first value, in this case inside parallelValue
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "parallelValue": [
                  {
                    "value": "Title 1"
                  },
                  {
                    "value": "Title 2"
                  }
                ]
              },
              {
                "value": "Title 3"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title 1')
        end
      end
    end

    describe 'parallelValue with additional value, value first, no primary' do
      # Select first value
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title 3"
              },
              {
                "parallelValue": [
                  {
                    "value": "Title 1"
                  },
                  {
                    "value": "Title 2"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title 3')
        end
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
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "structuredValue": [
                  {
                    "value": "A",
                    "type": "nonsorting characters"
                  },
                  {
                    "value": "title",
                    "type": "main title"
                  },
                  {
                    "value": "a subtitle",
                    "type": "subtitle"
                  },
                  {
                    "value": "Vol. 1",
                    "type": "part number"
                  },
                  {
                    "value": "Supplement",
                    "type": "part name"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'A title : a subtitle. Vol. 1, Supplement')
        end
      end
    end

    describe 'structuredValue with parts in uncommon order' do
      # improvement on stanford_mods in that it respects field order as given
      # based on ckey 9803970
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "structuredValue": [
                  {
                    "value": "The",
                    "type": "nonsorting characters"
                  },
                  {
                    "value": "title",
                    "type": "main title"
                  },
                  {
                    "value": "Vol. 1",
                    "type": "part number"
                  },
                  {
                    "value": "Supplement",
                    "type": "part name"
                  },
                  {
                    "value": "a subtitle",
                    "type": "subtitle"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'The title. Vol. 1, Supplement : a subtitle')
        end
      end
    end

    describe 'structuredValue with multiple partName and partNumber' do
      # improvement on stanford_mods in that it respects field order as given
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "structuredValue": [
                  {
                    "value": "Title",
                    "type": "main title"
                  },
                  {
                    "value": "Special series",
                    "type": "part name"
                  },
                  {
                    "value": "Vol. 1",
                    "type": "part number"
                  },
                  {
                    "value": "Supplement",
                    "type": "part name"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title. Special series, Vol. 1, Supplement')
        end
      end
    end

    describe 'structuredValue with part before title' do
      # improvement on stanford_mods in that it respects field order as given
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "structuredValue": [
                  {
                    "value": "Series 1",
                    "type": "part number"
                  },
                  {
                    "value": "Title",
                    "type": "main title"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Series 1. Title')
        end
      end
    end

    describe 'structuredValue with nonsorting character count' do
      # improvement on stanford_mods in that it does not force a space separator
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "structuredValue": [
                  {
                    "value": "L'",
                    "type": "nonsorting characters"
                  },
                  {
                    "value": "autre title",
                    "type": "main title"
                  }
                ],
                "note": [
                  {
                    "value": "2",
                    "type": "nonsorting character count"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'L\'autre title')
        end
      end
    end

    describe 'structuredValue for uniform title' do
      # Omit author name when uniform title is preferred title for display
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "structuredValue": [
                  {
                    "value": "Author, An",
                    "type": "name"
                  },
                  {
                    "value": "Title",
                    "type": "Title"
                  }
                ],
                "type": "uniform"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title')
        end
      end
    end

    # Handling punctuation

    describe 'punctuation/space in simple value' do
      # strip one or more instances of .,;:/\ plus whitespace at beginning or end of string
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "Title /"
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title')
        end
      end
    end

    describe 'punctuation/space in structuredValue' do
      # strip one or more instances of .,;:/\ plus whitespace at beginning or end of string
      xit 'not implemented' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "structuredValue": [
                  {
                    "value": "Title.",
                    "type": "main title"
                  },
                  {
                    "value": ":subtitle",
                    "type": "subtitle"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_display_title_tesim' do
          expect(doc).to include('sw_display_title_tesim' => 'Title : subtitle')
        end
      end
    end
  end
end
