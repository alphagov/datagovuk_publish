class Legacy::DatasetImportService
  attr_reader :obj, :orgs_cache, :themes_cache

  def initialize(obj, orgs_cache, themes_cache)
    @obj = obj
    @orgs_cache = orgs_cache
    @themes_cache = themes_cache
  end

  def run
    d = Dataset.find_or_create_by(uuid: obj["id"])
    d.legacy_name = obj["name"]
    d.title = obj["title"]
    d.summary = generate_summary(obj["notes"])
    d.description = obj["notes"]
    d.organisation_id = orgs_cache[obj["owner_org"]]
    d.frequency = build_frequency
    d.status = "draft"
    d.published_date = obj["metadata_created"]
    d.created_at = obj["metadata_created"]
    d.last_updated_at = obj["metadata_modified"]
    d.dataset_type = build_type
    d.harvested = harvested?(obj)
    d.contact_name = obj["contact-name"]
    d.contact_email = obj["contact-email"]
    d.contact_phone = obj["contact-phone"]
    d.foi_name = obj["foi-name"]
    d.foi_email = obj["foi-email"]
    d.foi_phone = obj["foi-phone"]
    d.foi_web = obj["foi-web"]
    d.location1 = build_location
    d.location2 = ""
    d.location3 = ""
    d.legacy_metadata = ""
    d.licence = build_licence
    d.licence_other = build_licence_other
    old_theme  = obj["theme-primary"]
    secondary_theme  = obj["theme-secondary"]
    d.theme_id = themes_cache.fetch(old_theme, nil)
    d.secondary_theme_id = themes_cache.fetch(secondary_theme, nil)
    d.save!(validate: false)

    # Add the inspire metadata if we have determined this is a ULKP
    # dataset.
    # if d.dataset_type == 'inspire'
    #   inspire = add_inspire_metadata(d.id, obj)
    #   inspire.save!(validate: false)
    # end

    if obj.has_key?('timeseries_resources')
      obj['timeseries_resources'].each do |resource|
        add_timeseries_datafiles(resource, d)
      end
    end

    if obj.has_key?('additional_resources')
      obj['additional_resources'].each do |resource|
        add_additional_info_datafiles(resource, d)
      end
    end

    d.status = "published"
    d.save!(validate: false)
  end

  def add_additional_info_datafiles(resource, dataset)
    datafile = Doc.find_or_create_by(url: resource["url"], dataset_id: dataset.id)
    base_attributes = create_datafile_base_attributes(resource, dataset)

    datafile.assign_attributes(base_attributes)
    datafile.save!(validate: false)
  end

  def add_timeseries_datafiles(resource, dataset)
    datafile = Link.find_or_create_by(url: resource["url"], dataset_id: dataset.id)
    base_attributes = create_datafile_base_attributes(resource, dataset)
    date_attributes = create_datafile_date_attributes(resource)

    datafile.assign_attributes(base_attributes)
    datafile.assign_attributes(date_attributes)

    datafile.save!(validate: false)
  end

  def create_datafile_base_attributes(resource, dataset)
    {
      uuid: resource["id"],
      format: resource["format"],
      name: datafile_name(resource),
      created_at: dataset.created_at,
      updated_at: dataset.last_updated_at
    }
  end

  def create_datafile_date_attributes(resource)
    dates = get_start_end_date(resource["date"])
    start_date = Date.parse(dates[0])
    end_date = Date.parse(dates[1])

    {
      start_date: start_date,
      end_date: end_date,
      # the month and year property are not stored but required to prevent Date validation error in Link model.
      # This does not seem right to me. Speak to Laurent and Jess
      month: end_date.month,
      year: end_date.year,
    }
  end

  def datafile_name(resource)
    resource['description'].strip == '' ? 'No name specified' : resource['description']
  end

  # DEPRECATED

  # def add_resource(resource, dataset)
  #   file_class = documentation?(resource['format']) ? Doc : Link
  #
  #   datafile = file_class.find_by(url: resource["url"], dataset_id: dataset.id)
  #   if datafile.nil?
  #     datafile = file_class.new(url: resource["url"], dataset_id: dataset.id)
  #     datafile.save!(validate: false)
  #   end
  #
  #   datafile.uuid = resource["id"]
  #   datafile.format = resource["format"]
  #   datafile.name = resource["description"]
  #   datafile.name = "No name specified" if datafile.name.strip() == ""
  #   datafile.created_at = dataset.created_at
  #   datafile.updated_at = dataset.last_updated_at
  #
  #   if !resource["date"].blank? && !documentation?(resource['format'])
  #     dates = get_start_end_date(resource["date"])
  #     if dataset.frequency != 'never'
  #       begin
  #         datafile.start_date = Date.parse(dates[0])
  #       rescue ArgumentError
  #         datafile.start_date = Date.new(1,1,1)
  #       end
  #       begin
  #         datafile.end_date = Date.parse(dates[1])
  #       rescue ArgumentError
  #         datafile.end_date = Date.new(1,1,1)
  #       end
  #     end
  #   end
  #
  #   datafile.save!(validate: false)
  # end

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

  def build_licence
    return 'no-licence' if licence.blank?
    return 'other' if licence != "uk-ogl"
    licence
  end

  def build_licence_other
    return licence if licence != "uk-ogl"
  end

  # Converts a legacy frequency into a new-style frequency
  def build_frequency
    freq = obj["update_frequency"]
    return 'never' if !freq

    new_frequency = {
      "annual"=> "annually",
      "quarterly"=> "quarterly",
      "monthly"=> "monthly"
    }[freq] || "never"

    # DEPRECATED

    # if new_frequency != "never"
    #   # Make sure all data resources have dates... if any don't we will
    #   # set frequency to never
    #   r = obj["resources"].select { |res|
    #     !documentation?(res["format"]) && res.fetch("date","").blank?
    #   }
    #
    #   if r.size > 0
    #     new_frequency = "never"
    #   end
    # end

    new_frequency
  end

  def build_location
    Array(obj["geographic_coverage"]).map(&:titleize).join(', ')
  end

  # Determine the type of dataset based on the presence of
  # a known INSPIRE key.
  def build_type
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

  private

  def licence
    obj["license_id"]
  end
end
