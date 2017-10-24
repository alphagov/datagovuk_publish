FactoryGirl.define do
  factory :dataset do
    organisation
    title "Price paid for dragon glass"
    summary "All transactions for dragon glass"
    legacy_name "ye-olde-slug"
    location1 "Westeros"
    frequency "never"
    licence "uk-ogl"
    last_updated_at Time.now
  end
end
