class Legacy::BetaSyncService
  ENDPOINTS = {
    modified_datasets: 'api/3/action/package_search?q=metadata_modified:[NOW-1DAY%20TO%20NOW]&rows=5000'.freeze,
    new_datasets: 'api/3/action/package_search?q=metadata_created:[NOW-1DAY%20TO%20NOW]&rows=5000'.freeze
  }

  def initialize(args)
    @orgs_cache = args[:orgs_cache]
    @theme_cache = args[:theme_cache]
    @logger = args[:logger]
    @legacy_server = args[:legacy_server]
    @count = 0
  end

  def run
    @logger.info "Importing legacy datasets...\r"
    [modified_datasets, new_datasets].each do |legacy_datasets|
      legacy_datasets.fetch('result', {}).fetch('results', []).each do |legacy_dataset|
        import legacy_dataset
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

  def import(legacy_dataset)
    legacy_dataset_id = legacy_dataset['id']
    @logger.info "Attempting to save legacy dataset to postgres and elasticsearch - legacy_id: #{legacy_dataset_id}"
    Legacy::DatasetImportService.new(legacy_dataset,@orgs_cache, @theme_cache).run
    Legacy::DatasetIndexService.new.index(legacy_dataset['id'])
    @logger.info "Legacy dataset saved - legacy_id: #{legacy_dataset_id}"
    @count += 1
  end
end
