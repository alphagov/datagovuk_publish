module CKAN
  module Modules
    module Pagination
      def depaginate(base_url, results_key = "results", offset_param = "start")
        results = []

        loop do
          params = { offset_param => results.count }
          url = append_url(base_url, params: params)

          page = JSON.parse(url.read)[results_key]
          results += page

          break if page.empty?
        end

        results
      end
    end
  end
end
