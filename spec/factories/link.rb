FactoryBot.define do
  factory :link do
    dataset
    url { 'http://google.com' }
    name { 'My link' }
  end
end
