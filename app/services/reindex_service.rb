class ReindexService
  attr_reader :batch_size, :client, :date, :logger, :new_index_name, :index_alias

  def initialize(args)
    @batch_size = args[:batch_size].to_i
    @logger = args[:logger]
    @client = args[:client]
    @date = Time.now.strftime '%Y%m%d%H%M%S'
    @new_index_name = "#{Dataset.index_name}_#{date}"
    @index_alias = "datasets-#{ENV['RAILS_ENV']}"
  end

  def run
    logger.info "Indexing #{published_datasets_count} datasets"
    index_datasets
    update_alias
    delete_old_indexes
    logger.info 'Import complete'
  end

  private

  def index_datasets
    create_new_index
    number_datasets_processed = 0

    Dataset.published.find_in_batches(batch_size: batch_size) do |datasets|
      logger.info "Batching #{datasets.length} datasets"
      bulk_index(datasets, new_index_name)
      number_datasets_processed += batch_size
    end
  end

  def update_alias
    remove_alias_from_old_index
    assign_alias_to_new_index
    logger.info 'Updated alias'
  end

  def delete_old_indexes
    aliases = client.indices.get_aliases.keys
    indexes_to_be_deleted = prepare_indexes_for_deletion aliases
    delete indexes_to_be_deleted
  rescue => e
    msg = "Failed to delete alias.\n#{e.message}"
    logger.error msg 
    Raven.capture_error msg
  end

  def create_new_index
    client.indices.create(
      index: @new_index_name, 
      body: { mappings: index_mapping }
    )
  end

  def remove_alias_from_old_index
    client.indices.update_aliases body: {
      actions: [
        {
          remove: {
            index: Dataset.index_name, 
            alias: index_alias
          }
        }
      ]
    }
  rescue
    logger.info 'No alias to remove'
  end

  def assign_alias_to_new_index
    client.indices.update_aliases body: {
      actions: [
        {
          add: {
            index: new_index_name, 
            alias: index_alias
          }
        }
      ]
    }
  rescue => e
    msg = "Could not update alias.\n #{e.msg}"
    logger.error msg
    Raven.capture_error msg
  end

  def published_datasets_count
    Dataset.published.count
  end

  def prepare_indexes_for_deletion(aliases)
    # Ensure that the three most recent indexes are kept
    aliases
      .select { |alias_name| alias_name.include? index_alias }
      .sort_by { |alias_name| Time.parse(alias_name.gsub(/"#{index_alias}_"/, '')) }
      .reverse
      .slice(2...-1)
  end

  def delete(indexes)
    indexes.each do |alias_name|
      client.indices.delete index: alias_name
      logger.info "Deleted #{alias_name}"
    end
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

  def bulk_index(datasets, new_index_name)
    client.bulk(
      index: new_index_name,
      type: ::Dataset.__elasticsearch__.document_type,
      body: prepare_records(datasets)
    )
  rescue => e
    msg = "There was an error indexing datasets:\n#{e.message}"
    logger.error msg
    Raven.capture msg
  end

  def prepare_records(datasets)
    datasets.map { |dataset| { index: { _id: dataset.id, data: dataset.as_indexed_json } } }
  end
end
