require 'util/metadata_tools'

class LegacyDatasetSync

  def initialize(orgs_cache:, theme_cache:, host:)
    @orgs_cache = orgs_cache
    @theme_cache = theme_cache
    @host = host
    @count = 0
  end

  def run
    puts "#{Time.now} - Starting legacy data sync with #{@host}"

    get_packages @host do |package|
      begin
        MetadataTools.add_dataset_metadata(package, @orgs_cache, @theme_cache)
      rescue => e
        puts e.message
      end

      print "Imported #{@count += 1} datasets...\r"
    end

    puts "#{Time.now} - Completed legacy data sync successfully"
  end

  private

  # Keep yielding recent packages until the metadata_modified
  # is earlier than yesterday.
  def get_packages(server)
    url = "#{server}/api/3/action/package_search?q=metadata_modified:[NOW-1DAY%20TO%20NOW]&rows=5000"
    data = fetch_json(url)
    return unless data

    data['result']['results'].each do |pkg|
      yield pkg
    end
  end

  # Fetch JSON from a URL
  def fetch_json(url)
    response = RestClient.get url
    return JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse
    puts "Failed to make the request to #{url}"
    return nil
  end
end
