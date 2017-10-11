require 'rest-client'

class LegacySyncWorker
  include Sidekiq::Worker

  def perform(id)
    json = Dataset.find(id).ckanify_metadata.to_json
    server =
      Rails.env.production? ? "https://data.gov.uk" : "https://test.data.gov.uk"
    url = "#{ server }/api/3/action/package_patch"
    headers = {Authorization: ENV["LEGACY_API_KEY"]}
    RestClient.post(url,json,headers)
  end

end
