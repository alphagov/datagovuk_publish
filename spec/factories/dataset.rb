FactoryGirl.define do
  factory :dataset do
    organisation { create :organisation }
    title 'dataset title'
    summary 'summary'
    frequency 'daily'
    licence_other 'other'
  end
end
