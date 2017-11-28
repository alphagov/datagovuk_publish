require 'base64'

def config
  return es_config_from_host if elastic_config['host'].present?
  return es_config_from_vcap if elastic_config['vcap_services'].present?
  Rails.logger.fatal "No elasticsearch environment variables found"
  return {}
end

def es_config_from_host
  {
    host: elastic_config['host'],
    transport_options: {
      request: {
        timeout: elastic_config['elastic_timeout']
      }
    }
  }
end

def es_config_from_vcap
  {
    host: es_server,
    transport_options: {
      request: {
        timeout: elastic_config['elastic_timeout']
      },
      ssl: {
        ca_file: es_cert_file.path
      }
    }
  }
end

def vcap
  JSON.parse(elastic_config['vcap_services'])
end

def elastic_config
  path = Rails.root.join('config', 'elasticsearch.yml')
  elastic_yaml_file = ERB.new File.new(path).read

  begin
    YAML.load(elastic_yaml_file.result(binding))[ENV['RAILS_ENV']]
  rescue => e
    Rails.logger.fatal "Failed to parse elasticsearch yaml configuration. Exiting"
    Rails.logger.fatal e
    exit
  end
end

def es_server
  vcap['elasticsearch'][0]['credentials']['uri'].chomp('/')
end

def es_cert_file
  begin
    File.open('elasticsearch_cert.pem', 'w') { |file| file.write es_cert }
  rescue => e
    Rails.logger.fatal "Failed to write elasticsearch certificate. Exiting"
    Rails.logger.fatal e
    exit
  end
end

def es_cert
  Base64.decode64(vcap['elasticsearch'][0]['credentials']['ca_certificate_base64'])
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)

Rails.logger.info "Elasticsearch config:"
Rails.logger.info config
