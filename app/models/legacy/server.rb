class Legacy::Server
  attr_reader :object

  def initialize(object:)
    @object = object
  end

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
    return "/api/3/action/package_patch" if object == :dataset
    return "/api/3/action/resource_patch" if object == :datafile
  end

  def headers
    { Authorization: ENV['LEGACY_API_KEY'] }
  end
end
