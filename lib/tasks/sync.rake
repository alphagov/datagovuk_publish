require 'rest-client'
require 'util/metadata_tools'

namespace :sync do

  desc "Synchronise datasets from Legacy DGU"
  task :daily => :environment do |_, args|

    orgs_cache =  Organisation.all.pluck(:uuid, :id).to_h
    theme_cache = Theme.all.pluck(:title, :id).to_h
    count = 0

    puts "#{Time.now} - Starting legacy data sync"

    get_packages "https://data.gov.uk" do |package|
      begin
        MetadataTools.add_dataset_metadata(package, orgs_cache, theme_cache)
      rescue Exception => e
        puts e
      end

      puts "Imported #{count+=1} datasets...\r"
    end

    puts "#{Time.now} - Completed legacy data sync successfully"
  end


  # Keep yielding recent packages until the metadata_modified
  # is earlier than yesterday.
  def get_packages(server)

    url = "#{server}/api/3/action/package_search?q=metadata_modified:[NOW-1DAY%20TO%20NOW]&rows=5000"

    data = fetch_json(url)
    return if !data

    data["result"]["results"].each do |pkg|
      yield pkg
    end

  end

  # Fetch JSON from a URL
  def fetch_json(url)
    begin
      response = RestClient.get url
      return JSON.parse(response.body)
    rescue RestClient::ExceptionWithResponse
      puts "Failed to make the request to #{url}"
      return nil
    end
  end

end
