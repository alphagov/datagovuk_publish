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
    add_date(ckan_datafile)
  end

  def update
    Legacy::Server.new.update(datafile_json)
  end

  private

  def add_date(ckan_datafile)
    if ["annually", "quarterly", "monthly"].include? dataset.frequency
      ckan_datafile["date"] =
        end_date.present? ? end_date.strftime("%d/%m/%Y") : created_at.strftime("%d/%m/%Y")
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
