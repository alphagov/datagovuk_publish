class Legacy::Datafile < SimpleDelegator

  def datafile_json
    {
      "id" => uuid,
      "name" => name,
      "format" => format,
      "resource_type" => 'file',
      "url" => url,
      "created" => created_at,
    }.compact.to_json
  end

  def update
    Legacy::Server.new(object: :datafile).update(datafile_json)
  end

end
