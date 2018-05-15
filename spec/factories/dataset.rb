FactoryGirl.define do
  factory :dataset do
    organisation
    title "Price paid for dragon glass"
    summary "All transactions for dragon glass"
    licence_code 'uk-ogl'
    legacy_name "ye-olde-slug"
    location1 "Westeros"
    frequency "never"
    licence "uk-ogl"
    topic
    last_updated_at Time.now
  end
end
