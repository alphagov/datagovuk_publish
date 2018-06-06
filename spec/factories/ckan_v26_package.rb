FactoryGirl.define do
  factory :ckan_v26_package, class: CKAN::V26::Package do
    name "Name"
    title "Title"
    notes "Notes"
    metadata_created Time.now.iso8601
    metadata_updated Time.now.iso8601
    license_id "uk-ogl"
    geographic_coverage %w[england scotland wales]
    owner_org SecureRandom.uuid

    add_attribute("theme-primary", "Environment & Fisheries")
    add_attribute("contact-name", "Mr. Contact")
    add_attribute("contact-email", "mr.contact@example.com")
    add_attribute("foi-name", "Mr. FOI")
    add_attribute("foi-email", "mr.foi@example.com")
    add_attribute("foi-web", "http://foi.com")

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
