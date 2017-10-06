namespace :search do

  desc "Reindex all datasets"
  task :reindex => :environment do |_, args|

    nb_datasets_to_index = Dataset.published.count

    puts "Indexing #{nb_datasets_to_index} datasets"

    datasetMappings = {
      dataset: {
        properties: {
          name: {
            type: "string",
            index: "not_analyzed"
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
            type: "nested",
            properties: {
              title: {
                type: "string",
                fields: {
                  raw: {
                    type: "string",
                    index: "not_analyzed"
                  }
                }
              }
            }
          }
        }
      }
    }

    Dataset.__elasticsearch__.client.indices.delete index: Dataset.__elasticsearch__.index_name rescue nil
    Dataset.__elasticsearch__.client.indices.create index: Dataset.__elasticsearch__.index_name, body: {mappings: datasetMappings}

    nb_dataset_processed = 0
    Dataset.published.find_in_batches(batch_size: 50) do |datasets|
      puts " Batching #{datasets.length} datasets (done #{nb_dataset_processed} / #{nb_datasets_to_index})"
      bulk_index(datasets)
      nb_dataset_processed = nb_dataset_processed + 50
    end
  end

  def bulk_index(datasets)
    begin
      Dataset.__elasticsearch__.client.bulk({
                                              index: ::Dataset.__elasticsearch__.index_name,
                                              type: ::Dataset.__elasticsearch__.document_type,
                                              body: prepare_records(datasets)
                                            })
    rescue => e
      puts "There was an error uploading datasets:"
      puts e
    end
  end

  def prepare_records(datasets)
    datasets.map do |dataset|
      {index: {_id: dataset.id, data: dataset.as_indexed_json}}
    end
  end

end
