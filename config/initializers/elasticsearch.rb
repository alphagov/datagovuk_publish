require 'base64'

CONFIG_PATH = Rails.root.join('config', 'elasticsearch.yml')
TEMPLATE = ERB.new File.new(CONFIG_PATH).read

begin
  ELASTIC_CONFIG = YAML.load(TEMPLATE.result(binding))[ENV['RAILS_ENV']]
rescue
  Rails.logger.fatal "Failed to parse elasticsearch yaml configuration. Exiting"
  exit
end

def log(server, filepath)
  Rails.logger.info "Configuring Elasticsearch on PAAS.\n
  Elasticsearch host: #{server}\n
  Elasticsearch cert file path: #{filepath}"
end

def create_es_cert_file(cert)
  es_cert_file = File.new('elasticsearch_cert.pem', 'w')
  es_cert_file.write(cert)
  es_cert_file.close
  es_cert_file
end


def es_config_production
  begin
    vcap = JSON.parse(ELASTIC_CONFIG['vcap_services'])
  rescue
    Rails.logger.fatal "Terminating as VCAP_SERVICES isn't valid JSON:"
    Rails.logger.fatal ELASTIC_CONFIG['vcap_services']
    exit
  end

  begin
    es_server = vcap['elasticsearch'][0]['credentials']['uri'].chomp('/')
    es_cert = Base64.decode64(vcap['elasticsearch'][0]['credentials']['ca_certificate_base64'])
  rescue
    Rails.logger.fatal "Failed to find elasticsearch information in VCAP_SERVICES"
    exit
  end

  begin
    es_cert_file = create_es_cert_file(es_cert)
  rescue
    Rails.logger.fatal "Failed to write elasticsearch certificate. Exiting"
    exit
  end

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
