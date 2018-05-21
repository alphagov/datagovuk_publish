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

    trait :with_datafile do
      datafiles { create_list(:datafile, 1) }
    end

    trait :with_doc do
      docs { create_list(:doc, 1) }
    end
  end
end
