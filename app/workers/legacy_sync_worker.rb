require 'rest-client'

class LegacySyncWorker
  include Sidekiq::Worker

  def perform(id)
    json = Dataset.find(id).ckanify_metadata
    server = "https://test.data.gov.uk"
    url = "#{ server }/api/3/action/package_patch"
    headers = {Authorization: "6c25593f-19fe-4064-a451-ddc0aff562d9"}
    RestClient.post(url,json,headers)
  end

end
