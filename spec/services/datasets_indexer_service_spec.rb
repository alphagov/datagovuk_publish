require 'rails_helper'

describe DatasetsIndexerService do
  it "indexes with the correct index mappings" do
    expected_mappings = {
      dataset: {
        properties: {
          name: {
            type: 'string',
            index: 'not_analyzed'
          },
          legacy_name: {
            type: 'string',
            index: 'not_analyzed'
          },
          uuid: {
            type: 'string',
            index: 'not_analyzed'
          },
          short_id: {
            type: 'string',
            index: 'not_analyzed'
          },
          location1: {
            type: 'string',
            fields: {
              raw: {
                type: 'string',
                index: 'not_analyzed'
              }
            }
          },
          organisation: {
            type: 'nested',
            properties: {
              title: {
                type: 'string',
                fields: {
                  raw: {
                    type: 'string',
                    index: 'not_analyzed'
                  }
                }
              }
            }
          },
          topic: {
            type: 'nested',
            properties: {
              title: {
                type: 'string',
                fields: {
                  raw: {
                    type: 'string',
                    index: 'not_analyzed'
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
