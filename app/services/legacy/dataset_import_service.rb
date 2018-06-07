class Legacy::DatasetImportService
  attr_reader :legacy_dataset, :orgs_cache, :topics_cache, :logger

  def initialize(legacy_dataset, orgs_cache, topics_cache, logger = Rails.logger)
    @legacy_dataset = legacy_dataset
    @orgs_cache = orgs_cache
    @topics_cache = topics_cache
    @logger = logger
  end

  def run
    update_or_create_dataset
    create_inspire_dataset(dataset.id) if dataset.dataset_type == 'inspire'
    create_datafiles
    create_documents
  end

  def update_or_create_dataset
    dataset.assign_attributes(dataset_attributes)
    dataset.save(validate: false)
  end

  def dataset_attributes
    licence_info = Licence.lookup(legacy_dataset["license_id"])

    {
      legacy_name: legacy_dataset["name"],
      title: legacy_dataset["title"],
      summary: build_summary(legacy_dataset["notes"]),
      description: legacy_dataset["notes"],
      organisation_id: orgs_cache[legacy_dataset["owner_org"]],
      frequency: build_frequency,
      published_date: legacy_dataset["metadata_created"],
      created_at: legacy_dataset["metadata_created"],
      last_updated_at: legacy_dataset["metadata_modified"],
      dataset_type: build_type,
      harvested: harvested?,
      contact_name: legacy_dataset["contact-name"],
      contact_email: legacy_dataset["contact-email"],
      contact_phone: legacy_dataset["contact-phone"],
      foi_name: legacy_dataset["foi-name"],
      foi_email: legacy_dataset["foi-email"],
      foi_phone: legacy_dataset["foi-phone"],
      foi_web: legacy_dataset["foi-web"],
      location1: build_location,
      licence_code: build_licence_code,
      licence_title: licence_info.title,
      licence_url: licence_info.url,
      licence_custom: get_extra("licence"),
      topic_id: build_topic_id,
      secondary_topic_id: build_secondary_topic_id,
      status: "published"
    }
  end

  def build_topic_id
    return unless legacy_dataset["theme-primary"]

    topic = convert_topic(legacy_dataset["theme-primary"])

    topics_cache.fetch(topic, nil)
  end

  def build_secondary_topic_id
    return unless legacy_dataset["theme-secondary"]

    topic = convert_topic(legacy_dataset["theme-secondary"].first)

    topics_cache.fetch(topic, nil)
  end

  def convert_topic(legacy_topic)
    return if legacy_topic.nil?

    legacy_topic
      .gsub('&', 'and')
      .tr(' ', '-')
      .downcase
  end

  def create_datafiles
    legacy_datafiles.each do |legacy_datafile|
      datafile = Datafile.find_or_create_by(url: legacy_datafile["url"], dataset_id: dataset.id)
      attributes = base_attributes_for_resource(legacy_datafile).merge(date_attributes_for_resource(legacy_datafile))
      datafile.assign_attributes(attributes)
      datafile.save!(validate: false)
    end
  end

  def create_documents
    legacy_documents.each do |legacy_document|
      document = Doc.find_or_create_by(url: legacy_document["url"], dataset_id: dataset.id)
      document.assign_attributes(base_attributes_for_resource(legacy_document))
      document.save!(validate: false)
    end
  end

  def base_attributes_for_resource(resource)
    {
      uuid: resource["id"],
      format: resource["format"],
      name: datafile_name(resource),
      created_at: resource["created"] || dataset.created_at,
      updated_at: resource["last_modified_at"] || resource["created"] || dataset.created_at
    }
  end

  def date_attributes_for_resource(resource)
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
    name = resource.fetch('name', '').squish
    name = resource.fetch('description', '').squish if name.blank?
    name.presence || 'No name specified'
  end

  def create_inspire_dataset(dataset_id)
    inspire = InspireDataset.find_or_create_by(dataset_id: dataset_id)
    inspire.access_constraints = get_extra('access_constraints')
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
  def build_summary(notes)
    return notes if notes && notes != ""
    "No description provided"
  end

  def build_licence_code
    licence
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

private

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
    if parts && (parts.length == 2)
      return calculate_dates_for_month(parts[0].to_i, parts[1].to_i)
    end
    ""
  end

  def calculate_dates_for_month(month, year)
    days = Time.days_in_month(month, year)
    "#{days}/#{month}/#{year}"
  end

  def calculate_dates_for_year(year)
    "31/12/#{year}"
  end

  def legacy_datafiles
    resources.reject { |resource| resource['resource_type'] == 'documentation' }
  end

  def legacy_documents
    resources.select { |resource| resource['resource_type'] == 'documentation' }
  end

  def resources
    Array(legacy_dataset['resources'])
  end

  def calculate_quarterly_dates(date_object)
    Date.new(date_object.year, 1 + (date_object.month - 1) / 4 * 4)
  end

  def dataset
    @dataset ||= Dataset.find_or_create_by(uuid: legacy_dataset["id"])
  end

  def get_extra(key, default: "")
    parsed_extras.fetch(key, default)
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
    legacy_dataset["license_id"].presence
  end
end
