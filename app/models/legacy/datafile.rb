class Legacy::Datafile < SimpleDelegator

  def update_payload
    {
      'id' => uuid,
      'description' => name,
      'format' => format,
      'date' => build_date,
      'resource_type' => build_datafile_type,
      'url' => url,
      'created' => created_at
    }.compact.to_json
  end

  def create_payload
    {
      'package_id' => dataset.ckan_uuid,
      'url' => url,
      'description' => name,
      'format' => format,
      'name' => name,
      'resource_type' => build_datafile_type,
      'size' => size,
      'created' => created_at

    }.compact.to_json
  end

  private

  def build_date
    return '' unless dataset.timeseries?
    end_date.presence.strftime('%d/%m/%Y')
  end

  def build_datafile_type
    return '' if type.blank?
    type == 'Doc' ? 'documentation' : 'file'
  end
end
