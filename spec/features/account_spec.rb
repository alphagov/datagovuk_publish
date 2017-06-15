require 'rails_helper'

describe "user page" do
  before(:each) do
    o = Organisation.new
    o.name = 'land-registry'
    o.title = 'Land Registry'
    o.save!()

    @user = User.create!(email:'test@localhost',
                         name: 'Test User',
                         primary_organisation: o,
                         password: 'password',
                         password_confirmation: 'password')

    visit '/'
    click_link 'Sign in'
    fill_in('user_email', with: 'test@localhost')
    fill_in('Password', with: 'password')
    click_button 'Sign in'
  end

  it "shows a page with the logged-in user's details" do
    click_link 'Test User'

    expect(page).to have_current_path "/account/#{@user.id}"
    expect(page).to have_content 'Test User'
    expect(page).to have_content 'test@localhost'
    expect(page).to have_content 'Land Registry'
  end

  it "returns 404 if the user doesn't exist" do
    click_link 'Test User'

    visit '/account/boom'
    expect(page.status_code).to be 404
  end

end
