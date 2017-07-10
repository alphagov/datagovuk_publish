config = {
  host: ENV.fetch("ES_HOST", "http://127.0.0.1:9200"),
  transport_options: {
    request: { timeout: 5 }
  }
}

if File.exist?("config/elasticsearch.yml")
  config.merge!(YAML.load_file("config/elasticsearch.yml")[Rails.env].symbolize_keys)
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)

# Reset the search index before testing
if Rails.env == "test"
  client = ::Dataset.__elasticsearch__.client
  client.indices.delete index: ::Dataset.__elasticsearch__.index_name
  client.indices.create index: ::Dataset.__elasticsearch__.index_name
end
