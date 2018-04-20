require 'csv'

namespace :delete do
  desc "Delete datasets with legacy_name (or UUID) listed in CSV from stdin"
  task :datasets => :environment do |_, args|
    CSV.parse(STDIN.read, :headers => false) do |row|
      legacy_name_or_uuid = row[0]

      dataset = Dataset.where(legacy_name: legacy_name_or_uuid).
        or(Dataset.where(uuid: legacy_name_or_uuid)).first

      if dataset.nil?
        Rails.logger.error "Could not find dataset for #{legacy_name_or_uuid}"
        next
      end

      unindex_dataset(dataset.uuid)
      force_delete_dataset(dataset)
    end
  end
end

def unindex_dataset(uuid)
  Rails.logger.info "Removing dataset from index #{uuid}"
  indexer = Legacy::DatasetIndexService.new
  indexer.remove_from_index(uuid)
end

def force_delete_dataset(dataset)
  Rails.logger.info "Deleting dataset #{dataset.name}/#{dataset.legacy_name}/#{dataset.uuid}"

  dataset.status = "draft".freeze
  dataset.destroy
end