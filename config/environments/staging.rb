require_relative "./production"

Rails.application.configure do
  config.assets.compile = true
  config.ckan_v26_base_url = "https://ckan.staging.publishing.service.gov.uk"
end
