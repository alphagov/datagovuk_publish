require 'ckan/v26/client'

module CKAN
  module V26
    class PackageDiffer
      CKAN_FIELDS = %i[id metadata_modified].freeze

      def call
        datasets = Dataset.where.not(legacy_name: nil)

        packages = client.search_dataset(fl: CKAN_FIELDS)
          .map { |response| Package.new(response) }

        {
          create: diff_create(packages, datasets),
          update: diff_update(packages, datasets),
          delete: diff_delete(packages, datasets)
        }
      end

    private

      def diff_create(packages, datasets)
        dataset_uuids = Set[*datasets.pluck(:uuid)]

        packages.reject do |package|
          dataset_uuids.include?(package.get("id"))
        end
      end

      def diff_update(packages, datasets)
        datasets_modified = Hash[datasets.pluck(:uuid, :updated_at)]
        datasets_status = Hash[datasets.pluck(:uuid, :status)]

        packages.to_a.select do |package|
          updated_at = datasets_modified[package.get("id")]
          (updated_at && package_is_changed?(package, updated_at)) || datasets_status[package.get("id")] == 'draft'
        end
      end

      def diff_delete(packages, datasets)
        package_uuids = packages.map { |package| package.get("id") }
        datasets.where.not(uuid: package_uuids)
      end

      def package_is_changed?(package, updated_at)
        updated_at.iso8601 < package.get("metadata_modified")
      end

      def client
        base_url = Rails.configuration.ckan_v26_base_url
        Client.new(base_url: base_url)
      end
    end
  end
end
