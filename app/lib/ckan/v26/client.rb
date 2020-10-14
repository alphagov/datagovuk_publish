require "open-uri"

module CKAN
  module V26
    class Client
      include CKAN::Modules::URLBuilder

      LIST_ORGANIZATION_PATH = "/api/3/action/organization_list".freeze
      SHOW_ORGANIZATION_PATH = "/api/3/action/organization_show".freeze
      SEARCH_DATASET_PATH = "/api/3/search/dataset".freeze
      SHOW_DATASET_PATH = "/api/3/action/package_show".freeze

      def initialize(base_url:)
        @base_url = URI(base_url)
      end

      def list_organization
        url = build_url(path: LIST_ORGANIZATION_PATH)
        JSON.parse(url.read)["result"]
      end

      def show_organization(id:)
        url = build_url(path: SHOW_ORGANIZATION_PATH, params: { id: id })
        JSON.parse(url.read)["result"]
      end

      def search_dataset(fl:, existing_total:) # rubocop:disable Naming/MethodParameterName
        url = build_url(path: SEARCH_DATASET_PATH, params: { q: "type:dataset", rows: 1000, fl: fl.join(",") })
        Depaginator.depaginate(url, existing_total: existing_total)
      end

      def show_dataset(id:)
        url = build_url(path: SHOW_DATASET_PATH, params: { id: id })
        JSON.parse(url.read)["result"]
      end
    end
  end
end
