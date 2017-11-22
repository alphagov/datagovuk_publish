class DatasetsIndexerService
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
      body: { mappings: index_mapping }
    )
  end

  def bulk_index(datasets)
    client.bulk(
      index: new_index_name,
      type: ::Dataset.__elasticsearch__.document_type,
      body: prepare_records(datasets)
    )
  rescue => e
    msg = "There was an error indexing datasets:\n#{e.message}"
    logger.error msg
    Raven.capture_exception msg
  end

  def index_mapping
    {
      dataset: {
        properties: {
          name: {
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
          }
        }
      }
    }
  end

  def prepare_records(datasets)
    datasets.map do |dataset|
      { index: { _id: dataset.id, data: dataset.as_indexed_json } }
    end
  end
end
