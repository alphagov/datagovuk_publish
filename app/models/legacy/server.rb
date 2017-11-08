class Legacy::Server

  def update(path, payload)
    url = URI.join(host, path).to_s
    LegacyUpdateWorker.perform_async(url, payload, headers)
  end

  def get(path)
    url = URI::join(host, path).to_s
    get_json url
  end

  private

  def host
    ENV.fetch('LEGACY_HOST')
  end

  def headers
    { Authorization: ENV.fetch('LEGACY_API_KEY') }
  end

  def get_json(url)
    response = RestClient.get url
    return JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse
    Raven.capture_exception "Failed to make the request to #{url}"
    return nil
  end
end
