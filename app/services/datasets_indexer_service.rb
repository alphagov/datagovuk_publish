class DatasetsIndexerService
  INDEX_SETTINGS = {
    analysis: {
      normalizer: {
        lowercase_normalizer: {
          type: "custom",
          filter: "lowercase"
        }
      }
    }
  }

  INDEX_MAPPINGS = {
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
        short_id: {
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
                }
              }
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
    Dataset.published.find_in_batches(batch_size: batch_size) do |datasets|
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
    prepared_datasets = prepare_records(datasets)
    DatasetIndexerWorker.perform_async(prepared_datasets, new_index_name)
  end

  def prepare_records(datasets)
    datasets.map do |dataset|
      { index: { _id: dataset.id, data: dataset.as_indexed_json } }
    end
  end
end
