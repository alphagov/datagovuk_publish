class Legacy::Server

  def update(payload)
    begin
      RestClient.post(url, payload, headers)
    rescue
      Rails.logger.debug "ERROR! => update not sent to legacy"
    end
  end

  private

  def url
    URI.join(host, path).to_s
  end

  def host
    Rails.env.production? ? "https://data.gov.uk" : "https://test.data.gov.uk"
  end

  def path
    "/api/3/action/package_patch"
  end

  def headers
    { Authorization: ENV['LEGACY_API_KEY'] }
  end

end
