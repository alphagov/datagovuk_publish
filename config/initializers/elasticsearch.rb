require 'base64'

vcap_services = ENV.fetch("VCAP_SERVICES", nil)

if vcap_services
  # we are running on PaaS
  vcap = JSON.parse(vcap_services)

  es_server = vcap['elasticsearch'][0]['credentials']['uri'].chomp("/")

  es_cert = Base64.decode64(vcap['elasticsearch'][0]['credentials']['ca_certificate_base64'])
  es_cert_file = File.new("/tmp/out.pem", "w")
  es_cert_file.puts(es_cert)
  es_cert_file.close

  puts es_server
  puts es_cert_file.path

  config = {
    host: es_server,
    transport_options: {
      request: { timeout: 5 },
      ssl: { ca_file: es_cert_file.path }
    }
  }
else
  es_server = ENV.fetch("ES_HOST", "http://127.0.0.1:9200")
  config = {
    host: es_server,
    transport_options: {
      request: { timeout: 5 }
    }
  }
end

if File.exist?("config/elasticsearch.yml")
  config.merge!(YAML.load_file("config/elasticsearch.yml")[Rails.env].symbolize_keys)
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)

# Reset the search index before testing
if Rails.env == "test"
  client = ::Dataset.__elasticsearch__.client
  begin
    client.indices.delete index: ::Dataset.__elasticsearch__.index_name
  rescue
    puts "No test search index to delete"
  end
  client.indices.create index: ::Dataset.__elasticsearch__.index_name
end
