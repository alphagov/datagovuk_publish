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
    get_legacy_datasets @host do |package|
      begin
        @logger.info "Attempting to save legacy dataset to postgres and elasticsearch - legacy_id: #{package["id"]}"
        MetadataTools.persist(package, @orgs_cache, @theme_cache)
        MetadataTools.index(package)
        @logger.info "Legacy dataset saved - legacy_id: #{package["id"]}"
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
  def get_legacy_datasets(server)
    modified_datasets_url = "#{server}/api/3/action/package_search?q=metadata_modified:[NOW-1DAY%20TO%20NOW]"
    new_datasets_url = "#{server}/api/3/action/package_search?q=metadata_created:[NOW-1DAY%20TO%20NOW]"

    new_legacy_datasets = fetch_json(new_datasets_url)
    modified_legacy_datasets = fetch_json(modified_datasets_url)

    [new_legacy_datasets, modified_legacy_datasets].each do |datasets|
      if there_are? datasets
        datasets['result']['results'].each do |pkg|
          yield pkg
        end
      end
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

  def there_are?(datasets)
    datasets['result'] && datasets['result']['results']
  end
end
