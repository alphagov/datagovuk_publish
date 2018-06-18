module CKAN
  module V26
    class CKANOrg
      def initialize(resource)
        @resource = resource
      end

      def get(key)
        @resource[key]
      end
    end
  end
end
