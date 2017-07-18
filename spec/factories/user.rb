FactoryGirl.define do
  factory :user do
    email 'test@localhost.co.uk'
    password 'password'
    password_confirmation 'password'
    name 'Test User'
  end
end
