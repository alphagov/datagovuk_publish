config = {
  host: ENV.fetch("ES_HOST", "http://127.0.0.1:9200"),
  transport_options: {
    request: { timeout: 5 }
  }
}

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
