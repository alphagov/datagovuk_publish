class Legacy::DatasetImportService
  attr_reader :obj, :orgs_cache, :themes_cache

  def initialize(obj, orgs_cache, themes_cache)
    @obj = obj
    @orgs_cache = orgs_cache
    @themes_cache = themes_cache
  end

  def dataset
    @dataset ||= Dataset.find_or_create_by(uuid: obj["id"])
  end

  def run
    update_or_create_dataset
    create_inspire_dataset(dataset.id) if dataset.dataset_type == 'inspire'
    create_datafiles(dataset)
  end

  def update_or_create_dataset
    dataset.legacy_name = obj["name"]
    dataset.title = obj["title"]
    dataset.summary = generate_summary(obj["notes"])
    dataset.description = obj["notes"]
    dataset.organisation_id = orgs_cache[obj["owner_org"]]
    dataset.frequency = build_frequency
    dataset.status = "draft"
    dataset.published_date = obj["metadata_created"]
    dataset.created_at = obj["metadata_created"]
    dataset.last_updated_at = obj["metadata_modified"]
    dataset.dataset_type = build_type
    dataset.harvested = harvested?
    dataset.contact_name = obj["contact-name"]
    dataset.contact_email = obj["contact-email"]
    dataset.contact_phone = obj["contact-phone"]
    dataset.foi_name = obj["foi-name"]
    dataset.foi_email = obj["foi-email"]
    dataset.foi_phone = obj["foi-phone"]
    dataset.foi_web = obj["foi-web"]
    dataset.location1 = build_location
    dataset.location2 = ""
    dataset.location3 = ""
    dataset.legacy_metadata = ""
    dataset.licence = build_licence
    dataset.licence_other = build_licence_other
    old_theme  = obj["theme-primary"]
    secondary_theme  = obj["theme-secondary"]
    dataset.theme_id = themes_cache.fetch(old_theme, nil)
    dataset.secondary_theme_id = themes_cache.fetch(secondary_theme, nil)
    dataset.save!(validate: false)
    dataset.status = "published"
    dataset.save!(validate: false)
  end

  def create_datafiles(dataset)
    resources.each do |resource|
      create_resource(resource, dataset)
    end
  end

  def create_resource(resource, dataset)
    datafile = find_or_initialize(resource)
    datafile.uuid = resource["id"]
    datafile.format = resource["format"]
    datafile.name = resource["description"].presence || "No name specified"
    datafile.created_at = dataset.created_at
    datafile.updated_at = dataset.last_updated_at

    if resource["date"].present? && !documentation?(resource['format'])
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

    datafile.day = datafile.end_date.day
    datafile.month = datafile.end_date.month
    datafile.year = datafile.end_date.year

    datafile.save!(validate: false)
  end

  def create_inspire_dataset(dataset_id)
    inspire = InspireDataset.find_or_create_by(dataset_id: dataset_id)
    inspire.bbox_east_long = get_extra('bbox-east-long')
    inspire.bbox_north_lat = get_extra('bbox-north-lat')
    inspire.bbox_south_lat = get_extra('bbox-south-lat')
    inspire.bbox_west_long = get_extra('bbox-west-long')
    inspire.coupled_resource = get_extra('coupled-resource')
    inspire.dataset_reference_date = get_extra('dataset-reference-date')
    inspire.frequency_of_update = get_extra('frequency-of-update')
    inspire.harvest_object_id = get_extra('harvest_object_id')
    inspire.harvest_source_reference = get_extra('harvest_source_reference')
    inspire.import_source = get_extra('import_source')
    inspire.metadata_date = get_extra('metadata-date')
    inspire.metadata_language = get_extra('metadata-language')
    inspire.provider = get_extra('provider')
    inspire.resource_type = get_extra('resource-type')
    inspire.responsible_party = get_extra('responsible-party')
    inspire.spatial = get_extra('spatial')
    inspire.spatial_data_service_type = get_extra('spatial-data-service-type')
    inspire.spatial_reference_system = get_extra('spatial-reference-system')
    inspire.guid = get_extra('guid')
    inspire.save!(validate: false)
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

    if new_frequency != "never"
      # Make sure all data resources have dates... if any don't we will
      # set frequency to never
      r = obj["resources"].select { |res|
        !documentation?(res["format"]) && res.fetch("date","").blank?
      }

      if r.size > 0
        new_frequency = "never"
      end
    end

    new_frequency
  end

  def build_location
    Array(obj["geographic_coverage"]).map(&:titleize).join(', ')
  end

  # Determine the type of dataset based on the presence of
  # a known INSPIRE key.
  def build_type
    if get_extra("UKLP") == "True"
      "inspire"
    else
      ""
    end
  end

  def harvested?
    get_extra("harvest_object_id") != ""
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

  private

  def get_extra(key)
    parsed_extras.fetch(key, "")
  end

  def parsed_extras
  # A typical extra value looks like:
  # { "key"=>"foo", "value"=>"bar"}
  # this method turns that into:
  # { "foo" => "bar" }
    extras.inject({}) do |result, hash|
      result[hash["key"]] = hash["value"]
      result
    end
  end

  def extras
    obj.fetch("extras", [])
  end

  def licence
    obj["license_id"]
  end

  def resources
    obj["resources"]
  end

  def find_or_initialize(resource)
    file_class(resource).find_or_initialize_by(url: resource["url"], dataset_id: dataset.id)
  end

  def file_class(resource)
    documentation?(resource['format']) ? Doc : Link
  end

  def documentation?(format)
    ['pdf', 'doc', 'docx'].include?(format.downcase)
  end
end
