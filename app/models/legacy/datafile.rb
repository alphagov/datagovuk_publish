class Legacy::Datafile < SimpleDelegator
  ENDPOINTS = {
    update: "/api/3/action/resource_patch"
  }

  def update
    Legacy::Server.new.update(path, payload)
  end

  def payload
    {
      id: uuid,
      description: name,
      format: format,
      date: build_date,
      resource_type: build_datafile_type,
      url: url,
      created: created_at
    }.to_json
  end

  private

  def path
    ENDPOINTS[:update]
  end

  def build_date
    return "" unless dataset.timeseries?
    end_date.presence.strftime("%d/%m/%Y")
  end

  def build_datafile_type
    return "" if type.blank?
    type == "Doc" ? "documentation" : "file"
  end
end
