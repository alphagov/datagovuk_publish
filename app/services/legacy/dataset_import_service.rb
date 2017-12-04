class Legacy::DatasetImportService
  attr_reader :legacy_dataset, :orgs_cache, :themes_cache

  def initialize(legacy_dataset, orgs_cache, themes_cache)
    @legacy_dataset = legacy_dataset
    @orgs_cache = orgs_cache
    @themes_cache = themes_cache
  end

  def run
    update_or_create_dataset
    create_inspire_dataset(dataset.id) if dataset.dataset_type == 'inspire'
    create_datafiles(dataset)
  end

  def update_or_create_dataset
    dataset.legacy_name = legacy_dataset["name"]
    dataset.title = legacy_dataset["title"]
    dataset.summary = generate_summary(legacy_dataset["notes"])
    dataset.description = legacy_dataset["notes"]
    dataset.organisation_id = orgs_cache[legacy_dataset["owner_org"]]
    dataset.frequency = build_frequency
    dataset.published_date = legacy_dataset["metadata_created"]
    dataset.created_at = legacy_dataset["metadata_created"]
    dataset.last_updated_at = legacy_dataset["metadata_modified"]
    dataset.dataset_type = build_type
    dataset.harvested = harvested?
    dataset.contact_name = legacy_dataset["contact-name"]
    dataset.contact_email = legacy_dataset["contact-email"]
    dataset.contact_phone = legacy_dataset["contact-phone"]
    dataset.foi_name = legacy_dataset["foi-name"]
    dataset.foi_email = legacy_dataset["foi-email"]
    dataset.foi_phone = legacy_dataset["foi-phone"]
    dataset.foi_web = legacy_dataset["foi-web"]
    dataset.location1 = build_location
    dataset.licence = build_licence
    dataset.licence_other = build_licence_other
    old_theme = legacy_dataset["theme-primary"]
    secondary_theme = legacy_dataset["theme-secondary"]
    dataset.theme_id = themes_cache.fetch(old_theme, nil)
    dataset.secondary_theme_id = themes_cache.fetch(secondary_theme, nil)
    dataset.status = "published"
    dataset.save!(validate: false)
  end

  def create_datafiles(dataset)
    create_timeseries_datafiles(dataset)
    create_non_timeseries_datafiles(dataset)
    create_additional_info_datafiles(dataset)
  end

  def create_additional_info_datafiles(dataset)
    if @legacy_dataset.has_key?('additional_resources')
      @legacy_dataset['additional_resources'].each do |resource|
        datafile = Doc.find_or_create_by(url: resource["url"], dataset_id: dataset.id)
        base_attributes = create_datafile_base_attributes(resource, dataset)

        datafile.assign_attributes(base_attributes)
        datafile.save!(validate: false)
      end
    end
  end

  def create_non_timeseries_datafiles(dataset)
    if @legacy_dataset.has_key?('individual_resources')
      @legacy_dataset['individual_resources'].each do |resource|
        datafile = Doc.find_or_create_by(url: resource["url"], dataset_id: dataset.id)
        base_attributes = create_datafile_base_attributes(resource, dataset)

        datafile.assign_attributes(base_attributes)
        datafile.save!(validate: false)
      end
    end
  end

  def create_timeseries_datafiles(dataset)
    if @legacy_dataset.has_key?('timeseries_resources')
      @legacy_dataset['timeseries_resources'].each do |resource|
        datafile = Link.find_or_create_by(url: resource["url"], dataset_id: dataset.id)
        base_attributes = create_datafile_base_attributes(resource, dataset)
        date_attributes = create_datafile_date_attributes(resource)

        datafile.assign_attributes(base_attributes)
        datafile.assign_attributes(date_attributes)

        datafile.save!(validate: false)
      end
    end
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
      day: end_date.day,
      month: end_date.month,
      year: end_date.year
    }
  end

  def datafile_name(resource)
    resource['description'].strip == '' ? 'No name specified' : resource['description']
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
    freq = legacy_dataset["update_frequency"]
    return 'never' if !freq

    new_frequency = {
      "annual" => "annually",
      "quarterly" => "quarterly",
      "monthly" => "monthly"
    }[freq] || "never"

    new_frequency
  end

  def build_location
    Array(legacy_dataset["geographic_coverage"]).map(&:titleize).join(', ')
  end

  # Determine the type of dataset based on the presence of
  # a known INSPIRE key.
  def build_type
    "inspire" if get_extra("UKLP") == "True"
  end

  def harvested?
    get_extra("harvest_object_id").present?
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

  def dataset
    @dataset ||= Dataset.find_or_create_by(uuid: legacy_dataset["id"])
  end

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
    legacy_dataset.fetch("extras", [])
  end

  def licence
    legacy_dataset["license_id"]
  end

  def resources
    legacy_dataset["resources"]
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
