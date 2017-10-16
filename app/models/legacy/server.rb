class Legacy::Server
  def update(payload)
    RestClient.put(url, payload, headers)
  end

  private

  def url
    "https://#{host}/#{path}"
  end

  def host
    Rails.env.production? ? "data.gov.uk" : "test.data.gov.uk"
  end

  def path
    "/api/3/action/package_patch"
  end

  def headers
    { Authorization: ENV['LEGACY_AUTH_TOKEN'] }
  end
end
