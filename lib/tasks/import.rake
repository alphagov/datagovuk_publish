require 'json'
require 'csv'
require 'zip'
require 'rest-client'

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
    logger = Logger.new(STDOUT)
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
    logger = Logger.new(STDOUT)
    orgs_cache = Organisation.all.pluck(:uuid, :id).to_h
    topic_cache = Topic.all.pluck(:name, :id).to_h
    theme_cache = Theme.all.pluck(:name, :id).to_h
    counter = 0

    logger.info 'Importing legacy datasets'
    json_from_lines(args.filename) do |legacy_dataset|
      counter += 1
      print "Completed #{counter}\r"
      DatasetImportWorker.perform_async(legacy_dataset, orgs_cache, theme_cache, topic_cache)
    end
    logger.info 'Import complete'
  end
end

# Given a filename, will execute a block on each line
# of the jsonl file, after the line has been decoded
# into as hashmap.
def json_from_lines(filename)
  File.foreach(filename).each do |line|
    yield JSON.parse(line)
  end
end
