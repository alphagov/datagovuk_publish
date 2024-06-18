require_relative "./production"

Rails.application.configure do
  config.assets.compile = true
  config.ckan_v26_base_url = ENV.fetch("CKAN_URL") { "https://ckan.eks.integration.govuk.digital" }
  config.test_publisher = ""
end
