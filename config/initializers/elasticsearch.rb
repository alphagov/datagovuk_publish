require 'base64'

CONFIG_PATH = "#{Rails.root}/config/elasticsearch.yml".freeze
TEMPLATE = ERB.new File.new(CONFIG_PATH).read
ELASTIC_CONFIG = YAML.load(TEMPLATE.result(binding))[ENV['RAILS_ENV']]

config = {
  host: ELASTIC_CONFIG['host'],
  transport_options: {
    request: { timeout: 5 }
  }
}

if ELASTIC_CONFIG['vcap_services'].present?
  vcap = JSON.parse(ELASTIC_CONFIG['vcap_services'])

  es_server = vcap['elasticsearch'][0]['credentials']['uri'].chomp('/')
  es_cert = Base64.decode64(vcap['elasticsearch'][0]['credentials']['ca_certificate_base64'])
  es_cert_file = File.new('/tmp/out.pem', 'w')
  es_cert_file.puts(es_cert)
  es_cert_file.close

  Rails.logger.info "Configuring Elasticsearch on PAAS.\n
  Elasticsearch host: #{es_server}\n
  Elasticsearch cert file path: #{es_cert_file.path}"

  config[:host] = es_server
  config[:transport_options][:ssl][:ca_file] = es_cert_file.path
end

ELASTIC = Elasticsearch::Client.new(config)
Elasticsearch::Model.client = ELASTIC
