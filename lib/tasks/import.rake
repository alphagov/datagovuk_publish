require 'json'

namespace :import do

  desc "Import organisations from a data.gov.uk dump"
  task :organisations, [:filename] => :environment do |_, args|
    count = 1

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

      o.save()

      print "Imported #{count} organisations...\r"
      count += 1
    end
    puts "\nDone"
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

