require 'json'
require 'csv'
require 'util/metadata_tools'

namespace :generate do
  desc "Generate a data.json file"
  task :datajson, [:filename] => :environment do |_, args|

    # We'll export this in blobs so that we don't load the
    # entire database into memory.
    file = File.new("data.json", "w+")

    generate_string().each do | blob |
      file.puts blob
    end

    file.close()
    File.rename "data.json", "public/data.json"
  end

  desc "Generate previews for files that don't have them"
  task previews: :environment do
    Link.all.each do |l|
      PreviewGenerationWorker.perform_async(l.id)
    end
  end

  desc "Drop all previews"
  task purge_previews: :environment do
    Preview.destroy_all
  end
end

# Generates a string to write to the output file. After the first
# call which will return the prelude, each successive call will
# return either a punctuation string, or a string representation
# of a dataset (as a json object).
def generate_string()
  Enumerator.new do |enum|
    enum.yield '{
      "@context"   : "https://project-open-data.cio.gov/v1.1/schema/catalog.jsonld",
      "@type"      : "dcat:Catalog",
      "conformsTo" : "https://project-open-data.cio.gov/v1.1/schema",
      "describedBy": "https://project-open-data.cio.gov/v1.1/schema/catalog.json",
      "dataset"    : ['

    count = 0

    Dataset.where(published: true).all.each do |dataset|
      enum.yield "," if count != 0
      enum.yield dataset_record(dataset)

      print "Encoded #{count+=1} datasets...\r"
    end

    enum.yield "\n]}"
  end
end

def dataset_record(dataset)
  record = {
    "@type":       "dcat:Dataset",
    identifier:  "https://data.gov.uk/dataset/#{dataset.name}",
    title:       dataset.title,
    description: dataset.summary,
    keyword:     [],
    issued:      dataset.created_at.iso8601,
    modified:    dataset.published_date.iso8601,
    accessLevel: "public",
    license:     licence_for_id(dataset.licence),
    publisher: {
      "@type": "org:Organization",
      name:  dataset.organisation.title
     }
  }

  resources = []
  dataset.datafiles.each do |file|
    resource = {
      "@type":     "dcat:Distribution",
      name:      file.name,
      accessURL: file.url,
      format:    file.format,
    }
    resources << resource
  end

  record["distribution"] = resources

  "\n#{record.to_json}"
end

def licence_for_id(id)
  id == "uk-ogl" ? "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/" : ""
end
