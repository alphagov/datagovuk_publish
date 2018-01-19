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
    child_organisation_count = 0
    relationships = {}

    logger.info 'Processing parent organisations'

    json_from_lines(args.filename) do |legacy_org|
      Legacy::OrganisationImportService.new(legacy_org).run
      organisation_count += 1
    end

    logger.info "Imported #{organisation_count} organisations...\r"
    logger.info "Processing #{relationships.size} child organisations"

    relationships.each do |child, parent|
      o = Organisation.find_by(name: child)
      o.parent = Organisation.find_by(name: parent)
      o.save!(validate: false)
      child_organisation_count += 1
    end
    logger.info "Assigned #{child_organisation_count} organisations...\r"

    logger.info "Import complete"
  end

  desc "Import datasets from a data.gov.uk dump"
  task :legacy_datasets, [:filename] => :environment do |_, args|
    # Maps the organisation UUIDs to the organisation IDs
    logger = Logger.new(STDOUT)
    orgs_cache = Organisation.all.pluck(:uuid, :id).to_h
    theme_cache = Theme.all.pluck(:title, :id).to_h
    counter = 0

    logger.info 'Importing legacy datasets'
    json_from_lines(args.filename) do |legacy_dataset|
      counter += 1
      print "Completed #{counter}\r"
      Legacy::DatasetImportService.new(legacy_dataset, orgs_cache, theme_cache).run
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
