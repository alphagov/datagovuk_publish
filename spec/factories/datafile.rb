FactoryGirl.define do
  factory :datafile do
    dataset
    url 'localhost:3000/datafile'
    name 'My Datafile'
  end
end
