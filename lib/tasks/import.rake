require 'json'
require 'csv'
require 'util/metadata_tools'

namespace :import do

  desc "Import locations from a CSV file"
  task :locations, [:filename] => :environment do |_, args|
    csv_text = File.read(args.filename)
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      Location.create!(row.to_hash)
    end
  end

  desc "Import organisations from a data.gov.uk dump"
  task :organisations, [:filename] => :environment do |_, args|
    count = 1

    relationships = {}

    json_from_lines(args.filename) do |obj|
      o = Organisation.find_by(name: obj["name"]) || Organisation.new

      o.name = obj["name"]
      o.title = obj["title"]
      o.description = obj["description"]
      o.abbreviation = obj["abbreviation"]
      o.replace_by = "#{obj['replaced_by']}"
      o.contact_email = obj["contact_email"]
      o.contact_phone = obj["contact_phone"]
      o.contact_name = obj["contact_name"]
      o.foi_email = obj["foi_email"]
      o.foi_phone = obj["foi_phone"]
      o.foi_name = obj["foi_name"]
      o.foi_web = obj["foi_web"]
      o.category = obj["category"]
      o.uuid = obj["id"]

      if ["ministerial-department", "non-ministerial-department",
          "devolved", "executive-ndpb", "advisory-ndpb",
          "tribunal-ndpb", "executive-agency",
          "executive-office", "gov-corporation"].include? obj["category"]
        o.org_type = "central-government"
      elsif obj["category"] == "local-council"
        o.org_type = "local-authority"
      else
        o.org_type = "other-government-body"
      end

      groups = obj["groups"] || []
      if groups.size != 0
        parent = groups[0]["name"]
        relationships[o.name] = parent
      end

      o.save()

      print "Imported #{count} organisations...\r"
      count += 1
    end

    puts "Processing #{relationships.size} child organisations"

    count = 0
    relationships.each do |child, parent|
      o = Organisation.find_by(name: child)
      o.parent = Organisation.find_by(name: parent)
      o.save!()
      print "Assigned #{count+=1} organisations...\r"
    end

    puts "\nDone"
  end

  desc "Import datasets from a data.gov.uk dump"
  task :datasets, [:filename] => :environment do |_, args|

    # Maps the organisation UUIDs to the organisation IDs
    orgs_cache =  Organisation.all.pluck(:uuid, :id).to_h
    theme_cache = Theme.all.pluck(:title, :id).to_h
    counter = 0

    json_from_lines(args.filename) do |obj|
      counter += 1
      print "Completed #{counter}\r"

      MetadataTools.add_dataset_metadata(obj, orgs_cache, theme_cache)
    end
  end

end

# Given a filename, will execute a block on each line
# of the jsonl file, after the line has been decoded
# into as hashmap.
def json_from_lines(filename)
  File.open(filename).each do |line|
    yield JSON.parse(line)
  end
end
