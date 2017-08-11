namespace :search do

  desc "Reindex all datasets"
  task :reindex => :environment do |_, args|

    puts "Indexing #{Dataset.where(published: true).count()} datasets"

    datasetMappings = {
      dataset: {
        properties: {
          name: {
            type: "string",
            index: "not_analyzed"
          },
          organisation: {
            type: "nested",
            properties: {
              name: {
                type: "string",
                index: "not_analyzed"
              }
            }
          }
        }
      }
    }

    Dataset.__elasticsearch__.client.indices.delete index: Dataset.__elasticsearch__.index_name rescue nil
    Dataset.__elasticsearch__.client.indices.create index: Dataset.__elasticsearch__.index_name, body: {mappings: datasetMappings}

    Dataset.where(published: true).find_in_batches(batch_size: 50) do |datasets|
      puts " Batching #{datasets.length} datasets"
      bulk_index(datasets)
    end
  end

  def bulk_index(datasets)
    begin
      Dataset.__elasticsearch__.client.bulk({
                                              index: ::Dataset.__elasticsearch__.index_name,
                                              type: ::Dataset.__elasticsearch__.document_type,
                                              body: prepare_records(datasets)
                                            })
    rescue
      puts "This batch of datasets was too large"
    end
  end

  def prepare_records(datasets)
    datasets.map do |dataset|
      {index: {_id: dataset.id, data: dataset.as_indexed_json}}
    end
  end

end
