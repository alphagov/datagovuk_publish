module CKAN
  module V26
    class InspireMapper
      def call(package)
        {
          access_constraints: package.get_extra('access_constraints'),
          bbox_east_long: package.get_extra('bbox-east-long'),
          bbox_north_lat: package.get_extra('bbox-north-lat'),
          bbox_south_lat: package.get_extra('bbox-south-lat'),
          bbox_west_long: package.get_extra('bbox-west-long'),
          coupled_resource: package.get_extra('coupled-resource'),
          dataset_reference_date: package.get_extra('dataset-reference-date'),
          frequency_of_update: package.get_extra('frequency-of-update'),
          harvest_object_id: package.get_extra('harvest_object_id'),
          harvest_source_reference: package.get_extra('harvest_source_reference'),
          import_source: package.get_extra('import_source'),
          metadata_date: package.get_extra('metadata-date'),
          metadata_language: package.get_extra('metadata-language'),
          provider: package.get_extra('provider'),
          resource_type: package.get_extra('resource-type'),
          responsible_party: package.get_extra('responsible-party'),
          spatial: package.get_extra('spatial'),
          spatial_data_service_type: package.get_extra('spatial-data-service-type'),
          spatial_reference_system: package.get_extra('spatial-reference-system'),
          guid: package.get_extra('guid')
        }
      end
    end
  end
end
