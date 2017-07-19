FactoryGirl.define do
  factory :task do
    organisation { create :organisation }
  end
end
