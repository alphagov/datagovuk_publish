class Legacy::Server
  ENDPOINTS = {
    update_dataset: "/api/3/action/package_patch",
    create_dataset: "/api/3/action/package_create",
    update_datafile: "/api/3/action/resource_patch",
    create_datafile: "/api/3/action/resource_create"
  }

  def update_legacy_dataset_url
    URI.join(host, ENDPOINTS[:update_dataset]).to_s
  end

  def create_legacy_dataset_url
    URI.join(host, ENDPOINTS[:create_dataset]).to_s
  end

  def update_legacy_datafile_url
    URI.join(host, ENDPOINTS[:update_datafile]).to_s
  end

  def create_legacy_datafile_url
    URI.join(host, ENDPOINTS[:create_datafile]).to_s
  end

  def get(path)
    url = URI::join(host, path).to_s
    get_json url
  end

  def headers
    { Authorization: ENV.fetch('LEGACY_API_KEY') }
  end

  private

  def host
    ENV.fetch('LEGACY_HOST')
  end

  def get_json(url)
    response = RestClient.get url
    return JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse
    Raven.capture_exception "Failed to make the request to #{url}"
    return nil
  end
end
