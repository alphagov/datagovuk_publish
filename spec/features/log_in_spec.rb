require 'rails_helper'

describe "logging in" do
  before(:each) do
    o = Organisation.create!
    User.create!(email: 'test@localhost',
                 name: 'Test User',
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

  it "displays an error if credentials are incorrect" do
    visit '/'
    click_link 'Sign in'
    fill_in('user_email', with: 'test@localhost')
    fill_in('Password', with: 'bad_password')
    click_button 'Sign in'
    expect(page).to have_content 'There was a problem signing you in'
  end

  it "logs out user successfully" do
    visit '/'
    click_link 'Sign in'
    fill_in('user_email', with: 'test@localhost')
    fill_in('Password', with: 'password')
    click_button 'Sign in'
    expect(page).to have_current_path '/tasks'
    click_link 'Sign out'
    expect(page).to have_current_path '/'
    expect(page).to have_content 'Publish and update data for your organisation'
  end
end
