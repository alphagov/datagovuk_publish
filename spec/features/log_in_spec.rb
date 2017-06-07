require 'rails_helper'

describe "logging in" do
  before(:each) do
    o = Organisation.create!
    User.create!(email:'test@localhost',
                 primary_organisation: o,
                 password: 'password',
                 password_confirmation: 'password')
  end

  it "can visit the index page" do
    visit '/'
    expect(page.status_code).to be 200
  end

  it "redirects logged in users" do
    visit '/'
    click_link 'Sign in'
    fill_in('user_email', with: 'test@localhost')
    fill_in('Password', with: 'password')
    click_button 'Sign in'
    expect(page).to have_current_path '/tasks'
  end
end
