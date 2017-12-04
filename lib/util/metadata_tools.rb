module MetadataTools

  def index(obj)
    dataset = Dataset.find_by!(uuid: obj["id"])

    dataset.__elasticsearch__.index_document({
      index: ::Dataset.__elasticsearch__.index_name,
      type: ::Dataset.__elasticsearch__.document_type,
      id: dataset.id, body: dataset.as_indexed_json
    })
  end

  def persist(obj, orgs_cache, theme_cache)
    publish_uuid = get_extra(obj["extras"], "publish_uuid")

    d = Dataset.find_or_create_by(uuid: publish_uuid)

    d.legacy_name = obj["name"]
    d.title = obj["title"]
    d.summary = generate_summary(obj["notes"])
    d.description = obj["notes"]
    d.organisation_id = orgs_cache[obj["owner_org"]]
    d.frequency = convert_frequency(obj)
    d.status = "draft"
    d.published_date = obj["metadata_created"]
    d.created_at = obj["metadata_created"]
    d.last_updated_at = obj["metadata_modified"]
    d.dataset_type = dataset_type(obj)
    d.harvested = harvested?(obj)
    d.contact_name = obj["contact-name"]
    d.contact_email = obj["contact-email"]
    d.contact_phone = obj["contact-phone"]
    d.foi_name = obj["foi-name"]
    d.foi_email = obj["foi-email"]
    d.foi_phone = obj["foi-phone"]
    d.foi_web = obj["foi-web"]
    d.location1 = convert_location(obj)
    d.location2 = ""
    d.location3 = ""
    d.legacy_metadata = ""
    d.licence = obj["license_id"]
    d.licence = 'no-licence' if d.licence == ""
    if !d.licence == "uk-ogl"
      d.licence = "other"
      d.licence_other = obj["license_id"]
    end
    old_theme  = obj["theme-primary"]
    secondary_theme  = obj["theme-secondary"]
    d.theme_id = theme_cache.fetch(old_theme, nil)
    d.secondary_theme_id = theme_cache.fetch(secondary_theme, nil)
    d.save!(validate: false)

    # Add the inspire metadata if we have determined this is a UKLP
    # dataset.
    if d.dataset_type == 'inspire'
      inspire = add_inspire_metadata(d.id, obj)
      inspire.save!(validate: false)
    end

    # Iterate over the resources list and add a new datafile for each
    # item.
    obj["resources"].each do |resource|
      add_resource(resource, d)
    end

    d.status = "published"
    d.save!(validate: false)
  end

  def add_resource(resource, dataset)
    file_class = documentation?(resource['format']) ? Doc : Link

    datafile = file_class.find_by(url: resource["url"], dataset_id: dataset.id)
    if datafile.nil?
      datafile = file_class.new(url: resource["url"], dataset_id: dataset.id)
      datafile.save!(validate: false)
    end

    datafile.uuid = resource["id"]
    datafile.format = resource["format"]
    datafile.name = resource["description"]
    datafile.name = "No name specified" if datafile.name.strip() == ""
    datafile.created_at = dataset.created_at
    datafile.updated_at = dataset.last_updated_at

    if !resource["date"].blank? && !documentation?(resource['format'])
      dates = get_start_end_date(resource["date"])
      if dataset.frequency != 'never'
        begin
          datafile.start_date = Date.parse(dates[0])
        rescue ArgumentError
          datafile.start_date = Date.new(1,1,1)
        end
        begin
          datafile.end_date = Date.parse(dates[1])
        rescue ArgumentError
          datafile.end_date = Date.new(1,1,1)
        end
      end
    end

    datafile.save!(validate: false)
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
    inspire.guid = get_extra(extras, 'guid')
    inspire
  end

  # Generates a summary from the provided notes as in
  # the legacy metadata we don't have a summary field.
  def generate_summary(notes)
    return notes if notes && notes != ""
    "No description provided"
  end

  # Converts a legacy frequency into a new-style frequency
  def convert_frequency(dataset)
    freq = dataset["update_frequency"]
    return 'never' if !freq

    new_frequency = {
      "annual"=> "annually",
      "quarterly"=> "quarterly",
      "monthly"=> "monthly"
    }[freq] || "never"

    if new_frequency != "never"
      # Make sure all data resources have dates... if any don't we will
      # set frequency to never
      r = dataset["resources"].select { |res|
        !documentation?(res["format"]) && res.fetch("date","").blank?
      }

      if r.size > 0
        new_frequency = "never"
      end
    end

    new_frequency
  end

  def convert_location(obj)
    loc = obj.fetch("geographic_coverage", [])
    if loc.is_a? Array
      loc.map(&:titleize).join(', ')
    else
      ""
    end
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
  def documentation?(fmt)
    ['pdf', 'doc', 'docx'].include? fmt.downcase
  end

  # Given a lax legacy date string, try and build a proper
  # date string that we can import
  def get_start_end_date(date_string)
    return ["", ""] if !date_string

    # eg "1983"
    if date_string.length == 4
      return calculate_dates_for_year(date_string.to_i)
    end

    # eg "1983/02/12"
    parts = date_string.split("/")
    if parts.length == 3
      return [date_string, date_string]
    end

    # eg "1983/02"
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

  module_function :persist, :index, :generate_summary, :convert_frequency, :add_inspire_metadata,
                  :dataset_type, :get_extra, :harvested?, :calculate_dates_for_month, :calculate_dates_for_year,
                  :documentation?, :get_start_end_date, :add_resource, :convert_location
end
