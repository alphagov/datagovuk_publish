class Legacy::Server

  def update(path, payload)
    url = URI.join(host, path).to_s
    LegacyUpdateWorker.perform_async(url, payload, headers)
  end

  private

  def host
    ENV.fetch('LEGACY_HOST')
  end

  def headers
    { Authorization: ENV.fetch('LEGACY_API_KEY') }
  end
end
