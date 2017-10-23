class Legacy::Server

  def update(payload)
    begin
      RestClient.post(url, payload, headers)
    rescue => e
      Rails.logger.debug "ERROR! => update not sent to legacy"
      raise e
    end
  end

  private

  def url
    URI.join(host, path).to_s
  end

  def host
    ENV['LEGACY_HOST']
  end

  def path
    "/api/3/action/package_patch"
  end

  def headers
    { Authorization: ENV['LEGACY_API_KEY'] }
  end
end
