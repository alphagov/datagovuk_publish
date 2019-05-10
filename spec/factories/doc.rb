FactoryBot.define do
  factory :doc do
    dataset
    url { 'http://google.com' }
    name { 'My Doc' }
  end
end
