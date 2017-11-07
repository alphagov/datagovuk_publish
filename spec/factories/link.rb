FactoryGirl.define do
  factory :link do
    dataset
    url 'http://google.com'
    name 'My Data Link'
    format 'CSV'
    start_date 1.month.ago
    end_date 1.week.ago
    type 'Link'
  end
end
