require 'ckan/v26/client'

module CKAN
  module V26
    class VersionDiff
      CKAN_FIELDS = %i[id metadata_modified].freeze

      def call
        packages = client.search_dataset(fl: CKAN_FIELDS)
        datasets = Dataset.where.not(legacy_name: nil)

        {
          create: diff_create(packages, datasets),
          update: diff_update(packages, datasets),
          delete: diff_delete(packages, datasets)
        }
      end

    private

      def diff_create(packages, datasets)
        dataset_uuids = Set[*datasets.pluck(:uuid)]
        packages.reject { |package| dataset_uuids.include?(package["id"]) }
      end

      def diff_update(packages, datasets)
        datasets = Hash[datasets.pluck(:uuid, :updated_at)]

        packages.to_a.select do |package|
          updated_at = datasets[package["id"]]
          updated_at && package_is_changed?(package, updated_at)
        end
      end

      def diff_delete(packages, datasets)
        package_uuids = packages.map { |package| package["id"] }
        datasets.where.not(uuid: package_uuids)
      end

      def package_is_changed?(package, updated_at)
        updated_at.iso8601 < package["metadata_modified"]
      end

      def client
        base_url = Rails.configuration.ckan_v26_base_url
        CKAN::V26::Client.new(base_url: base_url)
      end
    end
  end
end
