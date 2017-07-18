require 'rails_helper'

describe "user page" do

  let(:land_registry) { FactoryGirl.create(:organisation, name: 'land-registry', title: 'Land Registry') }
  let(:user) { FactoryGirl.create(:user, primary_organisation_id: land_registry.id) }

  before :each do
    create_user_and_sign_in
  end

  it "shows a page with the logged-in user's details" do
    click_link 'Test User'
    expect(page).to have_current_path "/account/#{user.id}"
    expect(page).to have_content 'Test User'
    expect(page).to have_content 'test@localhost.co.uk'
    expect(page).to have_content 'Land Registry'
  end

  it "returns 404 if the user doesn't exist" do
    click_link 'Test User'
    visit '/account/boom'
    expect(page.status_code).to be 404
  end

end
