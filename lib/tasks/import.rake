require 'json'
require 'pp'

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

  desc "Import datasets from a data.gov.uk dump"
  task :datasets, [:filename] => :environment do |_, args|

    # Maps the organisation UUIDs to the organisation IDs
    orgs_cache =  Organisation.all.pluck(:uuid, :id).to_h
    counter = 0

    json_from_lines(args.filename) do |obj|
      counter += 1
      if counter % 500 == 0
        puts "Completed #{counter}"
      end

      d = Dataset.find_or_create_by(name: obj["name"])
      d.uuid = obj["id"]
      d.title = obj["title"]
      d.summary = generate_summary(obj["notes"])
      d.description = obj["notes"]
      d.organisation_id = orgs_cache[obj["owner_org"]]
      d.licence = obj["license_id"]
      d.licence = 'no-licence' if d.licence == ""
      d.licence_other = ""
      d.frequency = convert_frequency(obj["update_frequency"])
      d.published = true
      d.published_date = obj["metadata_created"]
      d.created_at = obj["metadata_created"]
      d.updated_at = obj["metadata_modified"]
      d.dataset_type = dataset_type(obj)
      d.harvested = harvested?(obj)
      d.location1 = ""
      d.location2 = ""
      d.location3 = ""
      d.legacy_metadata = ""
      d.save!()

      # Add the inspire metadata if we have determined this is a ULKP
      # dataset.
      if d.dataset_type == 'inspire'
        inspire = add_inspire_metadata(d.id, obj)
        inspire.save!()
      end

      # Iterate over the resources list and add a new datafile for each
      # item.
      obj["resources"].each do |resource|
        datafile = Datafile.find_or_create_by(url: resource["url"], dataset_id: d.id)
        datafile.uuid = resource["id"]
        datafile.format = resource["format"]
        datafile.name = resource["description"]
        datafile.documentation = get_doc_type(resource['format'])
        datafile.created_at = d.created_at
        datafile.updated_at = d.updated_at

        if resource["date"]
          dates = get_start_end_date(resource["date"])
          datafile.start_date = dates[0]
          datafile.end_date   = dates[1]
        end

        datafile.save!()
      end

    end
  end

end

def add_inspire_metadata(dataset_id, dataset)
  extras = dataset["extras"]

  inspire = InspireDataset.find_or_create_by(dataset_id: dataset_id)
  inspire.bbox_east_long = get_extra(extras, 'bbox-east-long')
  inspire.bbox_north_lat = get_extra(extras, 'bbox-north-lat')
  inspire.bbox_south_lat = get_extra(extras, 'bbox-south-lat')
  inspire.bbox_west_long = get_extra(extras, 'bbox-west-long')
  inspire.coupled_resource = get_extra(extras, 'coupled-resource')
  inspire.dataset_reference_date = get_extra(extras, 'dataset-reference-date')
  inspire.frequency_of_update = get_extra(extras, 'frequency-of-update')
  inspire.harvest_object_id = get_extra(extras, 'harvest_object_id')
  inspire.harvest_source_reference = get_extra(extras, 'harvest_source_reference')
  inspire.import_source = get_extra(extras, 'import_source')
  inspire.metadata_date = get_extra(extras, 'metadata-date')
  inspire.metadata_language = get_extra(extras, 'metadata-language')
  inspire.provider = get_extra(extras, 'provider')
  inspire.resource_type = get_extra(extras, 'resource-type')
  inspire.responsible_party = get_extra(extras, 'responsible-party')
  inspire.spatial = get_extra(extras, 'spatial')
  inspire.spatial_data_service_type = get_extra(extras, 'spatial-data-service-type')
  inspire.spatial_reference_system = get_extra(extras, 'spatial-reference-system')
  inspire
end

# Given a filename, will execute a block on each line
# of the jsonl file, after the line has been decoded
# into as hashmap.
def json_from_lines(filename)
  File.open(filename).each do |line|
    yield JSON.parse(line)
  end
end

# Generates a summary from the provided notes as in
# the legacy metadata we don't have a summary field.
def generate_summary(notes)
  notes
end

# Converts a legacy frequency into a new-style frequency
def convert_frequency(freq)
  return 'never' if !freq

  {
    "annual"=> "annually",
    "quarterly"=> "quarterly",
    "monthly"=> "monthly"
  }[freq] || "never"
end

# Determine the type of dataset based on the presence of
# a known INSPIRE key.
def dataset_type(obj)
  if get_extra(obj["extras"], "UKLP") == "True"
    "inspire"
  else
    ""
  end
end

# Returns a value if the dataset is harvested, i.e. it has
# a harvest object id.
def harvested?(obj)
  get_extra(obj["extras"], "harvest_object_id") != ""
end

# Determine whether datafile is documentation or not
def get_doc_type(fmt)
  ['pdf', 'doc', 'docx'].include? fmt.downcase
end

# Given a lax legacy date string, try and build a proper
# date string that we can import
def get_start_end_date(date_string)
  return ["", ""] if !date_string

  if date_string.length == 4
    return calculate_dates_for_year(date_string.to_i)
  end

  parts = date_string.split("/")
  if parts.length == 3
    parts = parts.drop(0)
  end

  if parts and parts.length == 2
    return calculate_dates_for_month(parts[0].to_i, parts[1].to_i)
  end

  ["", ""]
end

# Date helpers
def calculate_dates_for_month(month, year)
  days = Time.days_in_month(month, year)
  ["1/#{month}/#{year}", "#{days}/#{month}/#{year}"]
end

def calculate_dates_for_year(year)
  ["1/1/#{year}", "31/12/#{year}"]
end

# Iterates through the hashes in the extras list looking
# for a matching key. If found will return the value
#
# A typical extra value looks like ...
#
# {"id"=>"7096e248-1129-422f-a4b9-5ee570cd2f75",
#  "key"=>"spatial-data-service-type",
#  "package_id"=>"00b14406-02bf-4021-b538-8069223da623",
#  "revision_id"=>"1e138922-8638-47b0-b15e-f87ff3b96f35",
#  "revision_timestamp"=>"2016-06-16T08:43:55.184222",
#  "state"=>"active",
#  "value"=>""}
def get_extra(extras, key)
  return "" if !extras

  result = extras.select{|hash| hash["key"] == key }.first
  return "" if !result

  result["value"]
end

