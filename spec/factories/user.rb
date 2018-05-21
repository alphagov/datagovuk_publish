FactoryGirl.define do
  factory :user do
    email 'test@localhost.co.uk'
    name 'Test User'
    organisation_content_id { SecureRandom.uuid }
    organisation_slug 'land-registry'
  end
end
