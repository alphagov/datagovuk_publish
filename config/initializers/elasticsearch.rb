config = {
  host: Rails.application.config_for(:elasticsearch)["host"],
  transport_options: {
    request: {
      timeout: Rails.application.config_for(:elasticsearch)['timeout']
    },
    ssl: {
      verify: false
    }
  }
}

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
