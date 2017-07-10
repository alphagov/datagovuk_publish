
namespace :search do

  desc "Reindex all datasets"
  task :reindex => :environment do |_, args|

    puts "Indexing #{Dataset.where(published: true).count()} datasets"

    Dataset.where(published: true).find_in_batches do |datasets|
      puts " Batching #{datasets.length} datasets"
      bulk_index(datasets)
    end

  end

  def bulk_index(datasets)
    Dataset.__elasticsearch__.client.bulk({
      index: ::Dataset.__elasticsearch__.index_name,
      type: ::Dataset.__elasticsearch__.document_type,
      body: prepare_records(datasets)
    })
  end

  def prepare_records(datasets)
    datasets.map do |dataset|
      { index: { _id: dataset.id, data: dataset.as_indexed_json } }
    end
  end

end
