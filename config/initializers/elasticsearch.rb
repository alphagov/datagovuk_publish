require 'base64'

CONFIG_PATH = "#{Rails.root}/config/elasticsearch.yml".freeze
TEMPLATE = ERB.new File.new(CONFIG_PATH).read
ELASTIC_CONFIG = YAML.load(TEMPLATE.result(binding))[ENV['RAILS_ENV']]

def log(server, filepath)
  Rails.logger.info "Configuring Elasticsearch on PAAS.\n
  Elasticsearch host: #{server}\n
  Elasticsearch cert file path: #{filepath}"
end

def es_config_production
  vcap = JSON.parse(ELASTIC_CONFIG['vcap_services'])

  es_server = vcap['elasticsearch'][0]['credentials']['uri'].chomp('/')
  es_cert = Base64.decode64(vcap['elasticsearch'][0]['credentials']['ca_certificate_base64'])
  es_cert_file = File.new('/tmp/out.pem', 'w')
  es_cert_file.puts(es_cert)
  es_cert_file.close

  log(es_server, es_cert_file.path)

  {
    host: es_server,
    transport_options: {
      request: {
        timeout: ELASTIC_CONFIG['elastic_timeout']
      },
      ssl: {
        ca_file: es_cert_file.path
      }
    }
  }
end

def es_config_non_production
  {
    host: ELASTIC_CONFIG['host'],
    transport_options: {
      request: {
        timeout: ELASTIC_CONFIG['elastic_timeout']
      }
    }
  }
end

config = ELASTIC_CONFIG['vcap_services'].present? ?
            es_config_production :
            es_config_non_production

ELASTIC = Elasticsearch::Client.new(config)
Elasticsearch::Model.client = ELASTIC
