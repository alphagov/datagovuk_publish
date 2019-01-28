FactoryBot.define do
  factory :ckan_v26_package, class: CKAN::V26::Package do
    name "Name"
    title "Title"
    notes "Notes"
    metadata_created "2015-10-06T11:21:26.185852"
    metadata_updated "2018-06-05T12:40:12.239474"
    license_id "uk-ogl"
    geographic_coverage %w[england scotland wales]
    owner_org SecureRandom.uuid

    add_attribute("theme-primary", "Environment & Fisheries")
    add_attribute("contact-name", "Mr. Contact")
    add_attribute("contact-email", "mr.contact@example.com")
    add_attribute("foi-name", "Mr. FOI")
    add_attribute("foi-email", "mr.foi@example.com")
    add_attribute("foi-web", "http://foi.com")
    add_attribute("schema", [{
      "url" => "https://github.com/datagovuk/schemas/tree/master/organogram",
      "id" => "d3c0b23f-6979-45e4-88ed-d2ab59b005d0",
      "title" => "Organisation structure including senior roles & salaries (org chart / organogram for central government departments and agencies)",
    }])

    extras do
      [{ "licence" => "Open Government Licence 3.0 (United Kingdom)" }]
    end

    trait :inspire do
      add_attribute("access_constraints", "[\"There are no public access constraints to this data. Use of this data is subject to the licence identified.\"]")
      add_attribute("bbox-east-long", "2.072")
      add_attribute("bbox-north-lat", "55.816")
      add_attribute("bbox-south-lat", "49.943")
      add_attribute("bbox-west-long", "-6.236")
      add_attribute("coupled-resource", "[]")
      add_attribute("dataset-reference-date", "[{\"type\": \"creation\", \"value\": \"2004-01-01\"}, {\"type\": \"revision\", \"value\": \"2018-04-30\"}]")
      add_attribute("frequency-of-update", "quarterly")
      add_attribute("harvest_object_id", SecureRandom.uuid)
      add_attribute("harvest_source_reference", SecureRandom.uuid)
      add_attribute("import_source", "harvest")
      add_attribute("metadata-date", "2018-06-05")
      add_attribute("metadata-language", "eng")
      add_attribute("provider", "")
      add_attribute("resource-type", "dataset")
      add_attribute("responsible-party", "Environment Agency (pointOfContact)")
      add_attribute("spatial", "{\"type\":\"Polygon\",\"coordinates\":[[[2.072, 49.943],[2.072, 55.816], [-6.236, 55.816], [-6.236, 49.943], [2.072, 49.943]]]}")
      add_attribute("spatial-data-service-type", "")
      add_attribute("spatial-reference-system", "http://www.opengis.net/def/crs/EPSG/0/27700")
      add_attribute("guid", SecureRandom.uuid)
    end

    trait :harvested do
      extras do
        [{ "key" => "harvest_object_id", "value" => SecureRandom.uuid }]
      end
    end

    initialize_with do
      CKAN::V26::Package.new(attributes.stringify_keys)
    end
  end
end
