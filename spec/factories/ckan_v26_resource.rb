FactoryBot.define do
  factory :ckan_v26_resource, class: CKAN::V26::Resource do
    url "http://environment.data.gov.uk/ds/wms?SERVICE=WMS&INTERFACE=ENVIRONMENT--86ec354f-d465-11e4-b09e-f0def148f590&request=GetCapabilities"
    format "WMS"
    name "Resource locator"
    description "Resource locator"
    created "2016-04-05T09:48:43.164470"
    resource_type "file"

    initialize_with do
      CKAN::V26::Resource.new(attributes.stringify_keys)
    end
  end
end
