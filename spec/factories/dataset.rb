FactoryBot.define do
  factory :dataset do
    organisation
    title { "Price paid for dragon glass" }
    summary { "All transactions for dragon glass" }
    legacy_name { "ye-olde-slug" }
    location1 { "Westeros" }
    frequency { "never" }
    licence_code { "uk-ogl" }
    topic
    status { "published" }

    after(:create) do |dataset, _|
      dataset.publish if dataset.published? # Make sure it's in Elasticsearch
    end

    trait :with_datafile do
      datafiles { create_list(:datafile, 1) }
    end

    trait :with_doc do
      docs { create_list(:doc, 1) }
    end

    trait :inspire do
      inspire_dataset { build :inspire_dataset }
    end
  end
end
