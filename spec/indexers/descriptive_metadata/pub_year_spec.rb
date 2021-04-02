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

  describe 'pub_year field' do
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
