def es_config_from_vcap
  begin
    vcap = JSON.parse(Rails.configuration.elasticsearch["vcap_services"])
    es_server = vcap["opensearch"][0]["credentials"]["uri"]
  rescue StandardError => e
    Rails.logger.fatal "Failed to extract ES creds from VCAP_SERVICES. Exiting"
    Rails.logger.fatal Rails.configuration.elasticsearch["vcap_services"]
    Rails.logger.fatal e
    return
  end

  es_config_from_host(es_server)
end

def es_config_from_host(host)
  {
    host: host,
    transport_options: {
      request: {
        timeout: Rails.configuration.elasticsearch["elastic_timeout"],
      },
    },
  }
end

if Rails.configuration.elasticsearch["host"]
  config = es_config_from_host(Rails.configuration.elasticsearch["host"])
elsif Rails.configuration.elasticsearch["vcap_services"]
  config = es_config_from_vcap
else
  Rails.logger.fatal "No elasticsearch environment variables found"
  config = nil
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
