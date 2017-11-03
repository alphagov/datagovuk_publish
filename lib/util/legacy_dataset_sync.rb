require 'util/metadata_tools'

class LegacyDatasetSync

  def initialize(orgs_cache:, theme_cache:, host:, logger:)
    @orgs_cache = orgs_cache
    @theme_cache = theme_cache
    @host = host
    @logger = logger
    @count = 0
  end

  def run
    @logger.info "Importing legacy datasets...\r"
    get_packages @host do |package|
        begin
          dataset_id = MetadataTools.add_dataset_metadata(package, @orgs_cache, @theme_cache)
          PublishingWorker.perform_async(dataset_id)
        rescue => e
          @logger.error e.message
        end
        @count += 1
    end
    @logger.info "Imported #{@count} datasets...\r"
  end

  private

  # Keep yielding recent packages until the metadata_modified and metadata_created
  # is earlier than yesterday.
  def get_packages(server)
    modified_url = "#{server}/api/3/action/package_search?q=metadata_modified:[NOW-1DAY%20TO%20NOW]"
    created_url = "#{server}/api/3/action/package_search?q=metadata_created:[NOW-1DAY%20TO%20NOW]"

    new_packages = fetch_json(created_url)
    modified_packages = fetch_json(modified_url)

    return unless new_packages || modified_packages

    new_packages['result']['results'].each do |pkg|
      yield pkg
    end

    modified_packages['result']['results'].each do |pkg|
      yield pkg
    end
  end

  # Fetch JSON from a URL
  def fetch_json(url)
    response = RestClient.get url
    return JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse
    @logger.error "Failed to make the request to #{url}"
    return nil
  end
end
