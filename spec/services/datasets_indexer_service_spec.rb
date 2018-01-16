require 'rails_helper'

describe DatasetsIndexerService do
  it "has the correct index mappings" do
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
          links: {
            type: "nested",
            properties: {
              format: { type: "keyword" }
            }
          }
        }
      }
    }

    expect(DatasetsIndexerService::INDEX_MAPPING).to eql(expected_mappings)
  end
end
