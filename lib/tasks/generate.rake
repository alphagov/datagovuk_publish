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

end

# Generates a string to write to the output file
def generate_string()
  Enumerator.new do |enum|
    enum.yield '{
      "@context"   : "https://project-open-data.cio.gov/v1.1/schema/catalog.jsonld",
      "@type"      : "dcat:Catalog",
      "conformsTo" : "https://project-open-data.cio.gov/v1.1/schema",
      "describedBy": "https://project-open-data.cio.gov/v1.1/schema/catalog.json",
      "dataset"    : ['

    first = true
    count = 0

    Dataset.where(published: true).all.each do |dataset|
      enum.yield "," if count == 0
      enum.yield dataset_record(dataset)

      print "Encoded #{count+=1} datasets...\r"
    end

    enum.yield "\n]}"
  end
end

def dataset_record(dataset)
  record = {
    "@type"      => "dcat:Dataset",
    "identifier" => "https://data.gov.uk/dataset/#{dataset.name}",
    "title"      => dataset.title,
    "description"=> dataset.summary,
    "keyword"    => [],
    "issued"     => "2016-05-04T10:56:04.000Z",
    "modified"   => "2016-08-12T19:25:20.565Z",
    "publisher"  => {
      "@type" => "org:Organization",
      'name'  => dataset.organisation.title
     },
    "accessLevel"=> "public",
    "license"    => licence_for_id(dataset.licence)
  }

  resources = []
  dataset.datafiles.each do |file|
    resource = {
      "@type"    => "dcat:Distribution",
      "name"      => file.name,
      "accessURL" => file.url,
      "format"    => file.format,
    }
    resources << resource
  end

  record["distribution"] = resources

  "\n#{record.to_json}"
end

def licence_for_id(id)
  return "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/" if id == "uk-ogl"
  ""
end
