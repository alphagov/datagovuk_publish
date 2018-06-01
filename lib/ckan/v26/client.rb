require 'ckan/modules/url_builder'
require 'ckan/modules/pagination'
require 'open-uri'

module CKAN
  module V26
    class Client
      include CKAN::Modules::URLBuilder
      include CKAN::Modules::Pagination

      SEARCH_DATASET_PATH = "/api/3/search/dataset".freeze

      def initialize(base_url:)
        @base_url = URI(base_url)
      end

      def search_dataset(fl:)
        depaginate(build_url(path: SEARCH_DATASET_PATH,
                             params: { rows: 1000, fl: fl.join(",") }))
      end
    end
  end
end
