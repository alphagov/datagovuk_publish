require 'json'
require 'csv'
require 'zip'
require 'rest-client'

namespace :import do
  desc "Import locations from a CSV file"
  task :locations, [:filename] => :environment do |_, args|
    csv_text = File.read(args.filename)
    csv = CSV.parse(csv_text, headers: true)
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
end

# Given a filename, will execute a block on each line
# of the jsonl file, after the line has been decoded
# into as hashmap.
def json_from_lines(filename)
  File.foreach(filename).each do |line|
    yield JSON.parse(line)
  end
end
