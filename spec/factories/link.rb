FactoryGirl.define do
  factory :link do
    dataset
    url 'http://google.com'
    name 'My Data Link'
    start_date Time.now.beginning_of_year
    end_date Time.now.end_of_year
  end
end
