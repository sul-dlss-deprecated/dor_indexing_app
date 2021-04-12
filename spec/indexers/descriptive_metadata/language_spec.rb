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

  describe 'language mappings from Cocina to Solr sw_language_ssim' do
    context 'when language code and text' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              value: 'English',
              code: 'eng',
              source: {
                code: 'iso639-2b'
              }
            }
          ]
        }
      end

      xit 'translates code to term' do
        expect(doc).to include('sw_language_ssim' => ['English'])
      end
    end

    context 'when language code only' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              code: 'eng',
              source: {
                code: 'iso639-2b'
              }
            }
          ]
        }
      end

      xit 'translates code to term' do
        expect(doc).to include('sw_language_ssim' => ['English'])
      end
    end

    context 'when language text only and matches term in mapping' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              value: 'English',
              source: {
                code: 'iso639-2b'
              }
            }
          ]
        }
      end

      xit 'includes language term' do
        expect(doc).to include('sw_language_ssim' => ['English'])
      end
    end

    context 'when language code only and not in mapping' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              code: 'enk',
              source: {
                code: 'iso639-2b'
              }
            }
          ]
        }
      end

      xit 'does not include a value' do
        expect(doc).not_to include('sw_language_ssim')
      end
    end

    context 'when language text only and not in mapping' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              value: 'Old English',
              source: {
                code: 'iso639-2b'
              }
            }
          ]
        }
      end

      xit 'does not include a value' do
        expect(doc).not_to include('sw_language_ssim')
      end
    end

    context 'when language code and text, only code in mapping' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              value: 'Old English',
              code: 'ang',
              source: {
                code: 'iso639-2b'
              }
            }
          ]
        }
      end

      xit 'translates code to term' do
        expect(doc).to include('sw_language_ssim' => ['English, Old (ca. 450-1100)'])
      end
    end

    context 'when language code and text, only text in mapping' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              value: 'English, Old (ca. 450-1100)',
              code: 'enk',
              source: {
                code: 'iso639-2b'
              }
            }
          ]
        }
      end

      xit 'includes text value' do
        expect(doc).to include('sw_language_ssim' => ['English, Old (ca. 450-1100)'])
      end
    end

    context 'when language code and text, neither in mapping' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              value: 'Old English',
              code: 'enk',
              source: {
                code: 'iso639-2b'
              }
            }
          ]
        }
      end

      xit 'does not include a value' do
        expect(doc).not_to include('sw_language_ssim')
      end
    end

    context 'when authority is ISO639-3 and code is in mapping' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              value: 'American Sign Language',
              code: 'ase',
              source: {
                code: 'iso639-3'
              }
            }
          ]
        }
      end

      xit 'translates code to term' do
        expect(doc).to include('sw_language_ssim' => ['American Sign Language'])
      end
    end

    context 'when code with non-ISO639 authority' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              code: 'eng',
              source: {
                code: 'rfc5646'
              }
            }
          ]
        }
      end

      xit 'does not include a value' do
        expect(doc).not_to include('sw_language_ssim')
      end
    end

    context 'when no ISO639 authority and language term in mapping' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              value: 'English'
            }
          ]
        }
      end

      xit 'includes language term' do
        expect(doc).to include('sw_language_ssim' => ['English'])
      end
    end

    context 'when language and script' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              value: 'English',
              code: 'eng',
              source: {
                code: 'iso639-2b'
              },
              script: {
                value: 'Latin',
                code: 'Latn',
                source: {
                  code: 'iso15924'
                }
              }
            }
          ]
        }
      end

      xit 'translates language code to term' do
        expect(doc).to include('sw_language_ssim' => ['English'])
      end
    end

    context 'when script without language' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              script: {
                value: 'Latin',
                code: 'Latn',
                source: {
                  code: 'iso15924'
                }
              }
            }
          ]
        }
      end

      xit 'does not include a value' do
        expect(doc).to include('sw_language_ssim')
      end
    end

    context 'when same language with multiple scripts' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              value: 'Chinese',
              code: 'chi',
              source: {
                code: 'iso639-2b'
              },
              script: {
                value: 'Han (Simplified variant)',
                code: 'Hans',
                source: {
                  code: 'iso15924'
                }
              }
            },
            {
              value: 'Chinese',
              code: 'chi',
              source: {
                code: 'iso639-2b'
              },
              script: {
                value: 'Han (Traditional variant)',
                code: 'Hant',
                source: {
                  code: 'iso15924'
                }
              }
            }
          ]
        }
      end

      xit 'translates language code to term and drops duplicate' do
        expect(doc).to include('sw_language_ssim' => ['Chinese'])
      end
    end

    context 'when multiple languages' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              value: 'English',
              code: 'eng',
              source: {
                code: 'iso639-2b'
              }
            },
            {
              value: 'Russian',
              code: 'rus',
              source: {
                code: 'iso639-2b'
              }
            }
          ]
        }
      end

      xit 'includes all languages' do
        expect(doc).to include('sw_language_ssim' => %w[English Russian])
      end
    end

    context 'when ISO639-2b authority URI and not authority code' do
      # URI may start with https
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              code: 'eng',
              source: {
                uri: 'http://id.loc.gov/vocabulary/iso639-2'
              }
            }
          ]
        }
      end

      xit 'translates code to term' do
        expect(doc).to include('sw_language_ssim' => ['English'])
      end
    end

    context 'when ISO639-3 authority URI and not authority code' do
      # URI may start with https
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              code: 'ase',
              source: {
                uri: 'http://iso639-3.sil.org/code/'
              }
            }
          ]
        }
      end

      xit 'translates code to term' do
        expect(doc).to include('sw_language_ssim' => ['English'])
      end
    end

    context 'when ISO639-2 value URI and not authority code' do
      # URI may start with https
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              code: 'eng',
              uri: 'http://id.loc.gov/vocabulary/iso639-2/eng'
            }
          ]
        }
      end

      xit 'translates code to term' do
        expect(doc).to include('sw_language_ssim' => ['English'])
      end
    end

    context 'when ISO639-3 value URI and not authority code' do
      # URI may start with https
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          language: [
            {
              code: 'ase',
              uri: 'http://iso639-3.sil.org/code/ase'
            }
          ]
        }
      end

      xit 'translates code to term' do
        expect(doc).to include('sw_language_ssim' => ['American Sign Language'])
      end
    end
  end
end
