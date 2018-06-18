module CKAN
  module Modules
    module JSONReader
      HEADERS = { 'Cache-Control' => 'no-cache' }.freeze

      def read_json(url)
        JSON.parse(url.read(HEADERS))
      end
    end
  end
end
