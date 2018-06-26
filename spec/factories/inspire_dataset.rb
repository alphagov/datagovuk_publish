FactoryGirl.define do
  factory :inspire_dataset do
    dataset_reference_date do
      "[{\"type\": \"publication\", \"value\": \"2015-12-03\"}, {\"type\": \"revision\", \"value\": \"2015-12-03\"}, {\"type\": \"creation\", \"value\": \"2006-01-01\"}]"
    end

    trait :invalid do
      dataset_reference_date do
        "[{\"type\": \"revision\", \"value\": \"2016-07\"}]"
      end
    end
  end
end
