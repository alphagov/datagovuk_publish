module CKAN
  module Modules
    module URLBuilder
      def append_url(url, params:)
        query = URI.decode_www_form(url.query || "")
        params = Hash[query].merge(params)

        url.query = URI.encode_www_form(params)
        url
      end

      def build_url(url = @base_url, path:, params: {})
        url = url.clone
        url.path = path
        append_url(url, params: params)
      end
    end
  end
end
