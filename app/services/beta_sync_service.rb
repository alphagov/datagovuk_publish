require 'util/metadata_tools'

class BetaSyncService
  ENDPOINTS = {
    modified_datasets: 'api/3/action/package_search?q=metadata_modified:[NOW-1DAY%20TO%20NOW]&rows=5000'.freeze,
    new_datasets: 'api/3/action/package_search?q=metadata_created:[NOW-1DAY%20TO%20NOW]&rows=5000'.freeze
  }

  def initialize(orgs_cache:, theme_cache:, logger:, legacy_server:)
    @orgs_cache = orgs_cache
    @theme_cache = theme_cache
    @logger = logger
    @legacy_server = legacy_server
    @count = 0
  end

  def run
    @logger.info "Importing legacy datasets...\r"
    [modified_datasets, new_datasets].each do |datasets|
      datasets.fetch('result', {}).fetch('results', []).each do |dataset|
        import dataset
      end
    end
    @logger.info "Imported #{@count} datasets...\r"
  end

  private

  def modified_datasets
    @legacy_server.get ENDPOINTS[:modified_datasets]
  end

  def new_datasets
    @legacy_server.get ENDPOINTS[:new_datasets]
  end

  def import(dataset)
    begin
      @logger.info "Attempting to save legacy dataset to postgres and elasticsearch - legacy_id: #{dataset["id"]}"
      MetadataTools.persist(dataset, @orgs_cache, @theme_cache)
      MetadataTools.index(dataset)
      @logger.info "Legacy dataset saved - legacy_id: #{dataset["id"]}"
    rescue => e
      Raven.capture_exception e.message
    end
    @count += 1
  end
end
