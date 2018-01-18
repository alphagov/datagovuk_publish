class Legacy::DatasetImportService
  attr_reader :legacy_dataset, :orgs_cache, :themes_cache

  def initialize(legacy_dataset, orgs_cache, themes_cache)
    @legacy_dataset = legacy_dataset
    @orgs_cache = orgs_cache
    @themes_cache = themes_cache
    @logger = Logger.new(STDOUT)
  end

  def run
    update_or_create_dataset
    create_inspire_dataset(dataset.id) if dataset.dataset_type == 'inspire'
    create_resources(dataset)
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

  def create_resources(dataset)
    create_datafiles(dataset)
    create_documents(dataset)
  end

  def create_datafiles(dataset)
    resources = Array(@legacy_dataset['resources'])
    legacy_datafiles = resources.select{ |resource| resource['resource_type'] == 'file'}
    legacy_datafiles.each do |legacy_datafile|
      datafile = Link.find_or_create_by(url: legacy_datafile["url"], dataset_id: dataset.id)
      base_attributes = create_resource_base_attributes(legacy_datafile, dataset)
      date_attributes = create_datafile_date_attributes(legacy_datafile)
      datafile.day = date_attributes[:day]
      datafile.month = date_attributes[:month]
      datafile.year = date_attributes[:year]
      datafile.assign_attributes(base_attributes)
      datafile.save!(validate: false)
    end
  end

  def create_documents(dataset)
    resources = Array(@legacy_dataset['resources'])
    legacy_documents = resources.select{ |resource| resource['resource_type'] == 'documentation'}
    legacy_documents.each do |legacy_document|
      document = Doc.find_or_create_by(url: legacy_document["url"], dataset_id: dataset.id)
      base_attributes = create_resource_base_attributes(legacy_document, dataset)

      document.assign_attributes(base_attributes)
      document.save!(validate: false)
    end
  end

  def create_resource_base_attributes(resource, dataset)
    {
      uuid: resource["id"],
      format: resource["format"],
      name: datafile_name(resource),
      created_at: resource["created"],
      updated_at: dataset.last_updated_at
    }
  end

  def create_datafile_date_attributes(resource)
    return {} if resource["date"].blank?
    date = get_end_date(resource["date"])
    end_date = parse_date(date)

    {
      day: end_date&.day,
      month: end_date&.month,
      year: end_date&.year
    }
  end

  def parse_date(date)
    Date.parse(date)
  rescue ArgumentError
    @logger.error("Invalid date detected: '#{date}'. Returning nil")
    nil
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
    return nil if licence.blank?
    return licence if licence != "uk-ogl"
  end

  # Converts a legacy frequency into a new-style frequency
  def build_frequency
    freq = legacy_dataset["update_frequency"]
    return 'never' if !freq

    new_frequency = {
      "annual" => "annually",
      "quarterly" => "quarterly",
      "monthly" => "monthly",
      "other" => "irregular"
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
  def get_end_date(date_string)
    # eg "1983"
    if date_string.length == 4
      return calculate_dates_for_year(date_string.to_i)
    end
     # eg "1983/02/12"
     parts = date_string.split("/")
   if parts.length == 3
     return date_string
   end
     # eg "1983/02"
   if parts and parts.length == 2
     return calculate_dates_for_month(parts[0].to_i, parts[1].to_i)
   end
    ""
  end

  # Date helpers

  def calculate_dates_for_month(month, year)
    days = Time.days_in_month(month, year)
    "#{days}/#{month}/#{year}"
  end

  def calculate_dates_for_year(year)
    "31/12/#{year}"
  end

  private

  def calculate_quarterly_dates(date_object)
    Date.new(date_object.year, 1+(date_object.month -1 )/4*4)
  end

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
end
