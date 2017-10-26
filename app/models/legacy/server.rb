class Legacy::Server

  def update(payload)
    begin
      RestClient.post(update_url, payload, headers)
    rescue => e
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>#{e.response.body}"
      Rails.logger.error "ERROR! => update not sent to legacy"
      raise e
    end
  end

  def show(uuid)
    begin
      RestClient.get(show_url(uuid).to_s)
    rescue => e
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{e.response.body}"
      Rails.logger.error("Could not fetch legacy resource #{uuid}: #{e}")
      nil
    end
  end

  private

  def show_url(uuid)
    URI.join(host, show_path(uuid))
  end

  def update_url
    URI.join(host, update_path).to_s
  end

  def host
    ENV['LEGACY_HOST']
  end

  def update_path
    return "/api/3/action/package_patch"
  end

  def create_path

  end

  def show_path(uuid)
    return "/api/3/action/package_show?id=#{uuid}"
  end

  def headers
    { Authorization: ENV['LEGACY_API_KEY'] }
  end

end
