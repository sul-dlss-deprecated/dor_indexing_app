# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescribableIndexer do
  # https://argo.stanford.edu/view/mn760md9509
  # https://argo.stanford.edu/view/sf449my9678
  subject(:indexer) { described_class.new(cocina: cocina) }

  let(:description) do
    <<~JSON
      "title": [{
        "structuredValue": [{
            "value": "The",
            "type": "nonsorting characters"
          },
          {
            "value": "complete works of Henry George",
            "type": "main title"
          }
        ],
        "note": [{
          "value": "4",
          "type": "nonsorting character count"
        }]
      }],
      "contributor": [{
          "name": [{
            "structuredValue": [{
                "value": "George, Henry",
                "type": "name"
              },
              {
                "value": "1839-1897",
                "type": "life dates"
              }
            ]
          }],
          "type": "person",
          "role": [{
            "value": "creator",
            "source": {
              "code": "marcrelator"
            }
          }]
        },
        {
          "name": [{
            "structuredValue": [{
                "value": "George, Henry",
                "type": "name"
              },
              {
                "value": "1862-1916",
                "type": "life dates"
              }
            ]
          }],
          "type": "person"
        }
      ],
      "event": [{
        "type": "publication",
        "date": [
          {
            "value": "1911",
            "status": "primary",
            "type": "publication",
            "encoding": {
              "code": "marc"
            }
          }
        ],
        "contributor": [{
          "name": [{
            "value": "Doubleday, Page"
          }],
          "type": "organization",
          "role": [{
            "value": "publisher",
            "code": "pbl",
            "uri": "http://id.loc.gov/vocabulary/relators/pbl",
            "source": {
              "code": "marcrelator",
              "uri": "http://id.loc.gov/vocabulary/relators/"
            }
          }]
        }],
        "location": [{
            "value": "Garden City, N. Y"
          },
          {
            "code": "xx",
            "source": {
              "code": "marccountry"
            }
          }
        ],
        "note": [{
            "value": "[Library ed.]",
            "type": "edition"
          },
          {
            "value": "monographic",
            "type": "issuance",
            "source": {
              "value": "MODS issuance terms"
            }
          }
        ]
      }],
      "form": [{
          "value": "text",
          "type": "resource type",
          "source": {
            "value": "MODS resource types"
          }
        },
        {
          "value": "electronic",
          "type": "form",
          "source": {
            "code": "marcform"
          }
        },
        {
          "value": "preservation",
          "type": "reformatting quality",
          "source": {
            "value": "MODS reformatting quality terms"
          }
        },
        {
          "value": "reformatted digital",
          "type": "digital origin",
          "source": {
            "value": "MODS digital origin terms"
          }
        }
      ],
      "language": [{
        "code": "eng",
        "source": {
          "code": "iso639-2b"
        }
      }],
      "note": [{
          "value": "On cover: Complete works of Henry George. Fels fund. Library edition."
        },
        {
          "value": "I. Progress and poverty.--II. Social problems.--III. The land question. Property in land. The condition of labor.--IV. Protection or free trade.--V. A perplexed philosopher [Herbert Spencer]--VI. The science of political economy, books I and II.--VII. The science of political economy, books III to V. \\"Moses\\": a lecture.--VIII. Our land and land policy.--IX-X. The life of Henry George, by his son Henry George, jr.",
          "type": "table of contents"
        }
      ],
      "identifier": [{
        "value": "druid:pz263ny9658",
        "type": "local",
        "displayLabel": "SUL Resource ID",
        "note": [{
          "value": "local",
          "type": "type",
          "uri": "http://id.loc.gov/vocabulary/identifiers/local",
          "source": {
            "uri": "http://id.loc.gov/vocabulary/identifiers/",
            "value": "Standard Identifier Schemes"
          }
        }]
      }],
      "subject": [
        {
          "structuredValue": [{
              "value": "Economics",
              "type": "topic"
            },
            {
              "value": "1800-1900",
              "type": "time"
            }
          ],
          "source": {
            "code": "lcsh"
          }
        },
        {
          "structuredValue": [{
              "value": "Economics",
              "type": "topic"
            },
            {
              "value": "Europe",
              "type": "place"
            }
          ],
          "source": {
            "code": "lcsh"
          }
        }
      ],
      "purl": "http://purl.stanford.edu/qy781dy0220",
      "access": {
        "physicalLocation": [{
          "value": "Stanford University Libraries"
        }],
        "digitalRepository": [{
          "value": "Stanford Digital Repository"
        }]
      },
      "relatedResource": [{
          "type": "has original version",
          "form": [{
              "value": "print",
              "type": "form",
              "source": {
                "code": "marcform"
              }
            },
            {
              "value": "10 v. fronts (v. 1-9) ports. 21 cm.",
              "type": "extent"
            }
          ],
          "adminMetadata": {
            "contributor": [{
              "name": [{
                "code": "YNG",
                "source": {
                  "code": "marcorg"
                }
              }],
              "type": "organization",
              "role": [{
                "value": "original cataloging agency"
              }]
            }],
            "event": [{
                "type": "creation",
                "date": [{
                  "value": "731210",
                  "encoding": {
                    "code": "marc"
                  }
                }]
              },
              {
                "type": "modification",
                "date": [{
                  "value": "19900625062034.0",
                  "encoding": {
                    "code": "iso8601"
                  }
                }]
              }
            ],
            "identifier": [{
                "value": "68184",
                "type": "SUL catalog key"
              },
              {
                "value": "757655",
                "type": "OCLC"
              }
            ]
          }
        },
        {
          "purl": "http://purl.stanford.edu/pz263ny9658",
          "access": {
            "digitalRepository": [{
              "value": "Stanford Digital Repository"
            }]
          }
        }
      ],
      "adminMetadata": {
        "contributor": [{
          "name": [{
            "value": "DOR_MARC2MODS3-3.xsl Revision 1.1"
          }]
        }],
        "event": [{
          "type": "creation",
          "date": [{
            "value": "2011-02-25T18:20:23.132-08:00",
            "encoding": {
              "code": "iso8601"
            }
          }]
        }],
        "identifier": [{
          "value": "36105010700545",
          "type": "Data Provider Digital Object Identifier"
        }]
      }
    JSON
  end
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
      	"description": {
          #{description}
      	},
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

  let(:cocina) { Cocina::Models.build(JSON.parse(json)) }

  describe '#to_solr' do
    let(:doc) { indexer.to_solr }

    it 'populates expected fields' do
      expect(doc).to eq(
        'metadata_format_ssim' => 'mods',
        'sw_language_ssim' => ['English'],
        'sw_format_ssim' => 'Book',
        'mods_typeOfResource_ssim' => ['text'],
        'sw_subject_temporal_ssim' => ['1800-1900'],
        'sw_subject_geographic_ssim' => ['Europe'],
        'sw_pub_date_facet_ssi' => '1911',
        'sw_author_tesim' => ['George, Henry (1839-1897)', 'George, Henry (1862-1916)'],
        'sw_display_title_tesim' => 'The complete works of Henry George'
      )
    end

    it 'does not include empty values' do
      doc.keys.sort_by(&:to_s).each do |k|
        expect(doc).to include(k)
        expect(doc).to match hash_excluding(k => nil)
        expect(doc).to match hash_excluding(k => [])
      end
    end

    context 'with translated title' do
      let(:description) do
        <<~JSON
          "title": [
            {
              "parallelValue": [
                {
                  "structuredValue": [
                    {
                      "value": "Toldot ha-Yehudim be-artsot ha-Islam",
                      "type": "main title"
                    },
                    {
                      "value": "ha-ʻet ha-ḥadashah-ʻad emtsaʻ ha-meʼah ha-19",
                      "type": "subtitle"
                    }
                  ]
                },
                {
                  "structuredValue": [
                    {
                      "value": "תולדות היהודים בארצות האיסלאם",
                      "type": "main title"
                    },
                    {
                      "value": "העת החדשה עד אמצע המאה ה־19",
                      "type": "subtitle"
                    }
                  ]
                }
              ]
            },
            {
              "value": "History of the Jews in the Islamic countries",
              "type": "alternative"
            }
          ]
        JSON
      end

      it 'populates expected fields' do
        expect(doc).to eq(
          'metadata_format_ssim' => 'mods',
          'sw_format_ssim' => 'Book',
          'sw_display_title_tesim' => 'Toldot ha-Yehudim be-artsot ha-Islam : ha-ʻet ha-ḥadashah-ʻad emtsaʻ ha-meʼah ha-19'
        )
      end
    end
  end

  describe 'pub_date field' do
    let(:doc) { indexer.to_solr }

    context 'when event has date.type publication and date.status primary' do
      let(:description) do
        <<~JSON
          "title": [
            {
              "value": "pub dates are fun",
              "type": "main title"
            }
          ],
          "event": [
            {
              "date": [
                {
                  "value": "1827",
                  "type": "creation"
                }
              ]
            },
            {
              "date": [
                {
                  "value": "1940",
                  "type": "publication",
                  "status": "primary"
                },
                {
                  "value": "1942",
                  "type": "publication"
                }
              ]
            }
          ]
        JSON
      end

      it 'populates sw_pub_date_facet_ssi' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '1940')
      end

      context 'when publication date is range (structuredValue)' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "pub dates are fun",
                "type": "main title"
              }
            ],
            "event": [
              {
                "date": [
                  {
                    "structuredValue": [
                      {
                        "value": "1940",
                        "status": "primary",
                        "type": "start"
                      },
                      {
                        "value": "1945",
                        "type": "end"
                      }
                    ],
                    "type": "publication"
                  },
                  {
                    "value": "1948",
                    "type": "publication"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_pub_date_facet_ssi' do
          expect(doc).to include('sw_pub_date_facet_ssi' => '1940')
        end
      end

      context 'when parallelEvent' do
        # based on sf449my9678
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "parallel publication event with status primary pub date"
              }
            ],
            "event": [
              {
                "parallelEvent": [
                  {
                    "date": [
                      {
                        "value": "1999-09-09",
                        "type": "publication",
                        "status": "primary"
                      }
                    ],
                    "location": [
                      {
                        "value": "Chengdu"
                      }
                    ]
                  },
                  {
                    "location": [
                      {
                        "value": "成都："
                      }
                    ]
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_pub_date_facet_ssi from parallelEvent date status primary with type publication' do
          expect(doc).to include('sw_pub_date_facet_ssi' => '1999')
        end
      end
    end

    context 'when event.type publication and event has date.type publication but no date.status primary' do
      let(:description) do
        <<~JSON
          "title": [
            {
              "structuredValue": [
                {
                  "value": "Work & social justice",
                  "type": "main title"
                }
              ]
            }
          ],
          "event": [
            {
              "date": [
                {
                  "value": "2018",
                  "type": "publication"
                }
              ]
            },
            {
              "type": "publication",
              "date": [
                {
                  "value": "2019",
                  "type": "publication"
                }
              ]
            },
            {
              "type": "copyright notice",
              "note": [
                {
                  "value": "©2020",
                  "type": "copyright statement"
                }
              ]
            }
          ]
        JSON
      end

      it 'populates sw_pub_date_facet_ssi' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2019')
      end

      context 'when publication date is range (structuredValue)' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "pub dates are fun",
                "type": "main title"
              }
            ],
            "event": [
              {
                "date": [
                  {
                    "value": "1957",
                    "type": "publication"
                  }
                ]
              },
              {
                "type": "publication",
                "date": [
                  {
                    "structuredValue": [
                      {
                        "value": "1940",
                        "type": "start"
                      },
                      {
                        "value": "1945",
                        "type": "end"
                      }
                    ],
                    "type": "publication"
                  }
                ]
              },
              {
                "type": "copyright notice",
                "note": [
                  {
                    "value": "©2020",
                    "type": "copyright statement"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_pub_date_facet_ssi with first date of structuredValue' do
          expect(doc).to include('sw_pub_date_facet_ssi' => '1940')
        end
      end

      context 'when parallelEvent' do
        # based on sf449my9678
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "parallelEvent with no status primary publication date"
              }
            ],
            "event": [
              {
                "parallelEvent": [
                  {
                    "date": [
                      {
                        "value": "2020-01-01",
                        "type": "publication"
                      }
                    ],
                    "location": [
                      {
                        "value": "Chengdu"
                      }
                    ]
                  },
                  {
                    "location": [
                      {
                        "value": "成都："
                      }
                    ]
                  }
                ]
              },
              {
                "type": "publication",
                "parallelEvent": [
                  {
                    "date": [
                      {
                        "value": "2021-01-01",
                        "type": "publication"
                      }
                    ],
                    "location": [
                      {
                        "value": "Chengdu"
                      }
                    ]
                  },
                  {
                    "location": [
                      {
                        "value": "成都："
                      }
                    ]
                  }
                ]
              }                ]
          JSON
        end

        it 'populates sw_pub_date_facet_ssi with first publication date of parallelValue of type publication' do
          expect(doc).to include('sw_pub_date_facet_ssi' => '2021')
        end
      end
    end

    context 'when event has date.type publication and no event.type publication' do
      let(:description) do
        <<~JSON
          "title": [
            {
              "value": "publication dates R us"
            }
          ],
          "event": [
            {
              "date": [
                {
                  "value": "1980-1984",
                  "type": "publication"
                }
              ]
            }
          ]
        JSON
      end

      it 'populates sw_pub_date_facet_ssi with first year of 1980-1984' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '1980')
      end

      context 'when publication date is range (structuredValue)' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "publication dates R us"
              }
            ],
            "event": [
              {
                "date": [
                  {
                    "structuredValue": [
                      {
                        "value": "1980",
                        "type": "start"
                      },
                      {
                        "value": "1984",
                        "type": "end"
                      }
                    ],
                    "type": "publication",
                    "encoding": {
                      "code": "marc"
                    }
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_pub_date_facet_ssi with first year of structuredValue' do
          expect(doc).to include('sw_pub_date_facet_ssi' => '1980')
        end
      end

      context 'when parallelEvent' do
        # based on sf449my9678
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "parallelEvent joy"
              }
            ],
            "event": [
              {
                "date": [
                  {
                    "structuredValue": [
                      {
                        "value": "1980",
                        "type": "start"
                      },
                      {
                        "value": "1984",
                        "type": "end"
                      }
                    ]
                  }
                ]
              },
              {
                "parallelEvent": [
                  {
                    "date": [
                      {
                        "value": "1966",
                        "type": "publication"
                      }
                    ],
                    "location": [
                      {
                        "value": "Chengdu"
                      }
                    ]
                  },
                  {
                    "location": [
                      {
                        "value": "成都："
                      }
                    ]
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_pub_date_facet_ssi with first publication date of parallelValue' do
          expect(doc).to include('sw_pub_date_facet_ssi' => '1966')
        end
      end
    end

    context 'when event has date.type creation, no date.type publication, and date.status primary' do
      let(:description) do
        <<~JSON
          "title": [
            {
              "value": "pub dates are fun",
              "type": "main title"
            }
          ],
          "event": [
            {
              "date": [
                {
                  "value": "1827",
                  "type": "validity"
                }
              ]
            },
            {
              "date": [
                {
                  "value": "1940-01-01",
                  "type": "creation",
                  "status": "primary",
                  "encoding": {
                    "code": "w3cdtf"
                  }
                },
                {
                  "value": "1942",
                  "type": "creation"
                }
              ]
            }
          ]
        JSON
      end

      it 'populates sw_pub_date_facet_ssi' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '1940')
      end

      context 'when creation date is range (structuredValue)' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "pub dates are fun",
                "type": "main title"
              }
            ],
            "event": [
              {
                "date": [
                  {
                    "structuredValue": [
                      {
                        "value": "1940",
                        "status": "primary",
                        "type": "start"
                      },
                      {
                        "value": "1945",
                        "type": "end"
                      }
                    ],
                    "type": "creation"
                  },
                  {
                    "value": "1948",
                    "type": "creation"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_pub_date_facet_ssi' do
          expect(doc).to include('sw_pub_date_facet_ssi' => '1940')
        end
      end

      context 'when parallelEvent' do
        # based on sf449my9678
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "parallel creation event with status primary pub date"
              }
            ],
            "event": [
              {
                "parallelEvent": [
                  {
                    "date": [
                      {
                        "value": "1999-09-09",
                        "type": "creation",
                        "status": "primary"
                      }
                    ],
                    "location": [
                      {
                        "value": "Chengdu"
                      }
                    ]
                  },
                  {
                    "location": [
                      {
                        "value": "成都："
                      }
                    ]
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_pub_date_facet_ssi from parallelEvent date status primary with type publication' do
          expect(doc).to include('sw_pub_date_facet_ssi' => '1999')
        end
      end
    end

    context 'when event.type creation and event has date.type creation but no date.status primary' do
      let(:description) do
        <<~JSON
          "title": [
            {
              "structuredValue": [
                {
                  "value": "Work & social justice",
                  "type": "main title"
                }
              ]
            }
          ],
          "event": [
            {
              "date": [
                {
                  "value": "2018",
                  "type": "creation"
                }
              ]
            },
            {
              "type": "creation",
              "date": [
                {
                  "value": "2019",
                  "type": "creation"
                }
              ]
            },
            {
              "type": "copyright notice",
              "note": [
                {
                  "value": "©2020",
                  "type": "copyright statement"
                }
              ]
            }
          ]
        JSON
      end

      it 'populates sw_pub_date_facet_ssi' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2019')
      end

      context 'when creation date is range (structuredValue)' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "pub dates are fun",
                "type": "main title"
              }
            ],
            "event": [
              {
                "date": [
                  {
                    "value": "1957",
                    "type": "creation"
                  }
                ]
              },
              {
                "type": "creation",
                "date": [
                  {
                    "structuredValue": [
                      {
                        "value": "1940",
                        "type": "start"
                      },
                      {
                        "value": "1945",
                        "type": "end"
                      }
                    ],
                    "type": "creation"
                  }
                ]
              },
              {
                "type": "copyright notice",
                "note": [
                  {
                    "value": "©2020",
                    "type": "copyright statement"
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_pub_date_facet_ssi with first date of structuredValue' do
          expect(doc).to include('sw_pub_date_facet_ssi' => '1940')
        end
      end

      context 'when parallelEvent' do
        # based on sf449my9678
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "parallelEvent with no status primary creation date"
              }
            ],
            "event": [
              {
                "parallelEvent": [
                  {
                    "date": [
                      {
                        "value": "2020-01-01",
                        "type": "creation"
                      }
                    ],
                    "location": [
                      {
                        "value": "Chengdu"
                      }
                    ]
                  },
                  {
                    "location": [
                      {
                        "value": "成都："
                      }
                    ]
                  }
                ]
              },
              {
                "type": "creation",
                "parallelEvent": [
                  {
                    "date": [
                      {
                        "value": "2021-01-01",
                        "type": "creation"
                      }
                    ],
                    "location": [
                      {
                        "value": "Chengdu"
                      }
                    ]
                  },
                  {
                    "location": [
                      {
                        "value": "成都："
                      }
                    ]
                  }
                ]
              }                ]
          JSON
        end

        it 'populates sw_pub_date_facet_ssi with first publication date of parallelValue of type publication' do
          expect(doc).to include('sw_pub_date_facet_ssi' => '2021')
        end
      end
    end

    context 'when event has date.type creation and no event.type creation' do
      let(:description) do
        <<~JSON
          "title": [
            {
              "value": "creation dates R us"
            }
          ],
          "event": [
            {
              "date": [
                {
                  "value": "1980-1984",
                  "type": "creation"
                }
              ]
            }
          ]
        JSON
      end

      it 'populates sw_pub_date_facet_ssi with first year of 1980-1984' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '1980')
      end

      context 'when creation date is range (structuredValue)' do
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "creation dates R us"
              }
            ],
            "event": [
              {
                "date": [
                  {
                    "structuredValue": [
                      {
                        "value": "1980",
                        "type": "start"
                      },
                      {
                        "value": "1984",
                        "type": "end"
                      }
                    ],
                    "type": "creation",
                    "encoding": {
                      "code": "marc"
                    }
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_pub_date_facet_ssi with first year of structuredValue' do
          expect(doc).to include('sw_pub_date_facet_ssi' => '1980')
        end
      end

      context 'when parallelEvent' do
        # based on sf449my9678
        let(:description) do
          <<~JSON
            "title": [
              {
                "value": "parallelEvent joy"
              }
            ],
            "event": [
              {
                "date": [
                  {
                    "structuredValue": [
                      {
                        "value": "1980",
                        "type": "start"
                      },
                      {
                        "value": "1984",
                        "type": "end"
                      }
                    ]
                  }
                ]
              },
              {
                "parallelEvent": [
                  {
                    "date": [
                      {
                        "value": "1966",
                        "type": "creation"
                      }
                    ],
                    "location": [
                      {
                        "value": "Chengdu"
                      }
                    ]
                  },
                  {
                    "location": [
                      {
                        "value": "成都："
                      }
                    ]
                  }
                ]
              }
            ]
          JSON
        end

        it 'populates sw_pub_date_facet_ssi with first publication date of parallelValue' do
          expect(doc).to include('sw_pub_date_facet_ssi' => '1966')
        end
      end
    end

    context 'when no event with desired date.type and no desired event.type' do
      let(:description) do
        <<~JSON
          "title": [
            {
              "structuredValue": [
                {
                  "value": "Work & social justice",
                  "type": "main title"
                }
              ]
            }
          ],
          "event": [
            {
              "type": "publication",
              "date": [
                {
                  "value": "2018",
                  "status": "primary",
                  "type": "copyright"
                }
              ]
            }
          ]
        JSON
      end

      it 'does not populate sw_pub_date_facet_ssi' do
        expect(doc).not_to include('sw_pub_date_facet_ssi')
      end
    end
  end
end
