FactoryBot.define do
  factory :organisation do
    name { "land-registry" }
    title { "Land Registry" }
    govuk_content_id { SecureRandom.uuid }
  end
end
