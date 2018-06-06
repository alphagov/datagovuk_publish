module CKAN
  module V26
    class Package
      def initialize(package)
        @package = package
      end

      def get(key)
        @package[key]
      end

      def get_extra(key)
        @extras ||= hashify(@package["extras"] || [])
        @extras[key]
      end

    private

      def hashify(array)
        array.inject({}) do |result, hash|
          result[hash["key"]] = hash["value"]; result
        end
      end
    end
  end
end
