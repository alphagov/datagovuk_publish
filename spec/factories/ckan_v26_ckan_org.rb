FactoryGirl.define do
  factory :ckan_v26_ckan_org, class: CKAN::V26::CKANOrg do
    id SecureRandom.uuid
    name "Name"

    add_attribute("contact-name", "Mr. Contact")
    add_attribute("contact-email", "mr.contact@example.com")
    add_attribute("foi-name", "Mr. FOI")
    add_attribute("foi-email", "mr.foi@example.com")
    add_attribute("foi-web", "http://foi.com")

    initialize_with do
      CKAN::V26::CKANOrg.new(attributes.stringify_keys)
    end
  end
end
