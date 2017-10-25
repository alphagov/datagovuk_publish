class Legacy::Datafile < SimpleDelegator

  def datafile_json
    ckan_datafile = {
      "id" => uuid,
      "description" => name,
      "format" => format,
      "resource_type" => converted_resource_type,
      "url" => url,
      "created" => created_at
    }.compact
    add_date(ckan_datafile).to_json
  end

  def update
    Legacy::Server.new(object: :datafile).update(datafile_json)
  end

  private

  def add_date(ckan_datafile)
    if ["annually", "quarterly", "monthly"].include? dataset.frequency
      ckan_datafile["date"] = end_date || Date.new(1,1,1)
    end
    ckan_datafile
  end

  def converted_resource_type
    if format == "Doc"
      "documentation"
    elsif format == "Link"
      "file"
    else
      ""
    end
  end

end
