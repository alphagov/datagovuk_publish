require 'rails_helper'

describe "logging in" do
  before(:each) do
    o = Organisation.create!
    PublishingUser.create!(email:'test@localhost',
                           primary_organisation: o,
                           password: 'password',
                           password_confirmation: 'password')
  end

  it "can visit the index page" do
    visit '/'
  end
end
