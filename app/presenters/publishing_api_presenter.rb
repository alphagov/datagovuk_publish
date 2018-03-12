class PublishingApiPresenter
  attr_reader :dataset, :update_type

  def initialize(dataset, update_type)
    @dataset = dataset
    @update_type = update_type
  end

  def render
    {
      title: dataset.title,
      base_path: base_path,
      description: dataset.description,
      schema_name: "dataset",
      document_type: "dataset",
      need_ids: [],
      public_updated_at: dataset.updated_at.to_datetime.rfc3339(3),
      publishing_app: "datagovuk-publish",
      rendering_app: "datagovuk-find",
      routes: routes,
      redirects: [],
      update_type: update_type,
      change_note: "",
      details: details,
      locale: "en",
    }
  end

  def details
    {
      name: dataset.name,
      frequency: dataset.frequency || "",
      licence: dataset.licence || "",
      summary: dataset.summary,
      datafiles: datafiles,
      organisation: organisation,
    }
  end

  def datafiles
    dataset.datafiles.map do |datafile|
      {
        url: datafile.url,
        uuid: datafile.uuid,
        name: datafile.name,
        format: datafile.format || "",
        size: datafile.format || 0,
        created_at: datafile.created_at.to_datetime.rfc3339(3),
        updated_at: datafile.updated_at.to_datetime.rfc3339(3),
      }
    end
  end

  def base_path
    "/dataset/#{dataset.uuid}/#{dataset.name}"
  end

  def organisation
    {
      title: dataset.organisation.title,
      name: dataset.organisation.name,
      description: dataset.organisation.description,
      abbreviation: dataset.organisation.abbreviation
    }
  end

  def routes
    [
      { path: base_path, type: "exact" },
    ]
  end
end
