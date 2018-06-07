module CKAN
  module V26
    class Resource
      def initialize(resource)
        @resource = resource
      end

      def get(key)
        @resource[key]
      end
    end
  end
end
