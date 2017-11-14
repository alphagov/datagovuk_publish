require 'json'
require 'csv'
require 'util/metadata_tools'
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
  task legacy_organisations: :environment do |_, args|

    count = 1

    relationships = {}

    puts 'Processing parent organisations'

    file = Tempfile.new('latest_organisations')
    file.binmode
    file.write(RestClient.get('https://data.gov.uk/data/dumps/data.gov.uk-ckan-meta-data-latest.organizations.jsonl.zip').body)
    file.close


    def read_json(filename)
      puts 'Reading zip file'

      Zip::File.open(filename.path) do |zip_file|
        zip_file.each do |file|
          data = zip_file.read(file)

          begin
            data.each_line do |line|
              yield JSON.parse(line)
            end
          rescue JSON::ParserError => e
            puts 'found an error'
            puts e.message
            puts e.backtrace
          end
        end
      end
    end

    read_json(file) do |obj|
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

        o.save(validate: false)

        puts "Imported #{count} organisations...\r"
        count += 1
      # end
    end

    puts "Processing #{relationships.size} child organisations"
    count = 0
    relationships.each do |child, parent|
      o = Organisation.find_by(name: child)
      o.parent = Organisation.find_by(name: parent)
      o.save!(validate: false)
      # parent_organisations.push o
      print "Assigned #{count+=1} organisations...\r"
    end

    puts "\nDone"

  end

  desc "Import datasets from a data.gov.uk dump"
  task :datasets, [:filename] => :environment do |_, args|
    Link.skip_callback(:save, :before, :set_dates)

    # Maps the organisation UUIDs to the organisation IDs
    orgs_cache = Organisation.all.pluck(:uuid, :id).to_h
    theme_cache = Theme.all.pluck(:title, :id).to_h
    counter = 0

    json_from_lines(args.filename) do |obj|
      counter += 1
      print "Completed #{counter}\r"

      MetadataTools.persist(obj, orgs_cache, theme_cache)
    end
  end

end

# Given a filename, will execute a block on each line
# of the jsonl file, after the line has been decoded
# into as hashmap.
def json_from_lines(filename)
  File.foreach(filename).each do |line|
    yield JSONL.parse(line)
  end
end
