require 'json'
require 'csv'
require 'zip'
require 'rest-client'

LEGACY_SHOW_API = 'https://data.gov.uk/api/3/action/package_show'

namespace :import do

  desc "Import locations from a CSV file"
  task :locations, [:filename] => :environment do |_, args|
    csv_text = File.read(args.filename)
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      Location.create!(row.to_hash)
    end
  end

  desc "Import organisations from legacy"
  task :legacy_organisations, [:filename] => :environment do |_, args|
    logger = Rails.logger
    Organisation.delete_all
    organisation_count = 0

    json_from_lines(args.filename) do |legacy_org|
      Legacy::OrganisationImportService.new(legacy_org).run
      organisation_count += 1
      print "Importing #{organisation_count} organisations\r"
    end

    logger.info "Organisation import complete"
  end

  desc "Import datasets from a data.gov.uk dump"
  task :legacy_datasets, [:filename] => :environment do |_, args|
    # Maps the organisation UUIDs to the organisation IDs
    logger = Rails.logger

    InspireDataset.delete_all
    Link.delete_all
    Dataset.delete_all
    counter = 0

    logger.info 'Importing legacy datasets'
    json_from_lines(args.filename) do |legacy_dataset|
      counter += 1
      print "Completed #{counter}\n" if (counter % 10).zero?
      Legacy::DatasetImportService.new(legacy_dataset, organisation_cache, topic_cache).run
    end
    logger.info 'Import complete'
  end

  desc "Import a single legacy dataset from the legacy API"
  task :single_legacy_dataset, [:legacy_shortname] => :environment do |_, args|
    logger = Rails.logger

    begin
      api_parameters = { params: { id: args.legacy_shortname } }
      api_response = RestClient.get LEGACY_SHOW_API, api_parameters
    rescue RestClient::ExceptionWithResponse => e
      logger.error "Request to API to retrieve #{args.legacy_shortname} responded with: #{e.response.code}"
      next
    end

    legacy_dataset = JSON.parse(api_response).fetch('result')
    Legacy::DatasetImportService.new(legacy_dataset, organisation_cache, topic_cache).run

    indexer = Legacy::DatasetIndexService.new
    indexer.remove_from_index(legacy_dataset['id'])
    indexer.index(legacy_dataset['id'])
  end
end

def topic_cache
  @topic_cache ||= Topic.all.pluck(:name, :id).to_h
end

def organisation_cache
  @organisation_cache ||= Organisation.all.pluck(:uuid, :id).to_h
end

# Given a filename, will execute a block on each line
# of the jsonl file, after the line has been decoded
# into as hashmap.
def json_from_lines(filename)
  File.foreach(filename).each do |line|
    yield JSON.parse(line)
  end
end
