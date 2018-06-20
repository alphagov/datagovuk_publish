class DatasetsIndexerService
  INDEX_SETTINGS = {
    blocks: {
      read_only: false
    },
    analysis: {
      normalizer: {
        lowercase_normalizer: {
          type: "custom",
          filter: "lowercase"
        }
      }
    }
  }.freeze

  INDEX_MAPPINGS = {
    dataset: {
      properties: {
        name: {
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
              ignore_above: 10000
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
        legacy_name: {
          type: 'keyword',
          index: true,
        },
        uuid: {
          type: 'keyword',
          index: true,
        },
        location1: {
          type: 'text',
          fields: {
            raw: {
              type: 'keyword',
              index: true,
            },
          },
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
  }.freeze

  def initialize(args)
    @batch_size = args[:batch_size]
    @date = args[:date]
    @new_index_name = args[:new_index_name]
    @client = args[:client]
    @logger = args[:logger]
  end

  def run
    number_datasets_processed = 0

    create_new_index
    Dataset.published.includes(:organisation, :topic, :inspire_dataset, :datafiles, :docs).find_in_batches(batch_size: batch_size) do |datasets|
      logger.info "Batching #{datasets.length} datasets"
      bulk_index(datasets)
      number_datasets_processed += batch_size
    end

    logger.info "Datasets indexed to #{new_index_name}"
  end

private

  attr_reader :date, :new_index_name, :batch_size, :client, :logger

  def create_new_index
    client.indices.create(
      index: new_index_name,
      body: {
        settings: INDEX_SETTINGS,
        mappings: INDEX_MAPPINGS
      }
    )
  end

  def bulk_index(datasets)
    Dataset.__elasticsearch__.client.bulk(
      index: new_index_name,
      type: ::Dataset.__elasticsearch__.document_type,
      body: prepare_records(datasets)
    )
  rescue Elasticsearch::Transport::Transport::Error => e
    logger.warn(e)
    retry
  end

  def prepare_records(datasets)
    datasets.map do |dataset|
      { index: { _id: dataset.uuid, data: dataset.as_indexed_json } }
    end
  end
end
