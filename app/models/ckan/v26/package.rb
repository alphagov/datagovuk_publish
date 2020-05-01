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

      def get_harvest(key)
        @harvest ||= hashify(@package["harvest"] || [])
        @harvest[key]
      end

      def resources
        @package["resources"].map { |resource| Resource.new(resource) }
      end

    private

      def hashify(array)
        array.each_with_object({}) do |hash, result|
          result[hash["key"]] = hash["value"]
        end
      end
    end
  end
end
