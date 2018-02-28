require 'rails_helper'

describe DatasetsIndexerService do
  it "indexes with the correct index mappings" do
    expected_mappings = {
      dataset: {
        properties: {
          name: {
            type: 'keyword',
            index: true,
          },
          legacy_name: {
            type: 'keyword',
            index: true,
          },
          uuid: {
            type: 'keyword',
            index: true,
          },
          title: {
            type: 'text',
            fields: {
              keyword: {
                type: 'keyword',
                index: true,
              },
              english: {
                type: 'text',
                analyzer: 'english',
              },
            },
          },
          summary: {
            type: 'text',
            fields: {
              keyword: {
                type: 'keyword',
                index: true,
              },
              english: {
                type: 'text',
                analyzer: 'english',
              },
            },
          },
          description: {
            type: 'text',
            fields: {
              keyword: {
                type: 'keyword',
                index: true,
              },
              english: {
                type: 'text',
                analyzer: 'english',
              },
            },
          },
          location1: {
            type: 'text',
            fields: {
              raw: {
                type: 'keyword',
                index: true,
              }
            }
          },
          organisation: {
            type: 'nested',
            properties: {
              title: {
                type: 'text',
                fields: {
                  raw: {
                    type: 'keyword',
                    index: true,
                  },
                  english: {
                    type: 'text',
                    analyzer: 'english',
                  },
                },
              },
              description: {
                type: 'text',
                fields: {
                  raw: {
                    type: 'keyword',
                    index: true,
                  },
                  english: {
                    type: 'text',
                    analyzer: 'english',
                  },
                },
              }
            }
          },
          topic: {
            type: 'nested',
            properties: {
              title: {
                type: 'text',
                fields: {
                  raw: {
                    type: 'keyword',
                    index: true,
                  }
                }
              }
            }
          },
          datafiles: {
            type: "nested",
            properties: {
              format: {
                type: "keyword",
                normalizer: "lowercase_normalizer"
              }
            }
          },
          docs: {
            type: "nested",
            properties: {
              format: {
                type: "keyword",
                normalizer: "lowercase_normalizer"
              }
            }
          }
        }
      }
    }

    expect(DatasetsIndexerService::INDEX_MAPPINGS).to eql(expected_mappings)
  end

  it "uses a lowercase normalizer to tokenize the datafile format" do
    expected_settings = {
      analysis: {
        normalizer: {
          lowercase_normalizer: {
            type: "custom",
            filter: "lowercase"
          }
        }
      }
    }

    expect(DatasetsIndexerService::INDEX_SETTINGS).to eql(expected_settings)
  end
end
