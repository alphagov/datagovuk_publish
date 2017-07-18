require 'rails_helper'

describe "Location API" do
  before(:each) do
    org = Organisation.new
    org.name = 'land-registry'
    org.title = 'Land Registry'
    org.save!()

    User.create!(email:'test@localhost',
                 name: 'Test User',
                 primary_organisation: org,
                 password: 'password',
                 password_confirmation: 'password')
    Location.create!( name: 'England', location_type: '')
    Location.create!( name: 'Melton', location_type: 'local authority')
    Location.create!( name: 'Medway', location_type: 'NHS Clinical Commissioning Group area')
    Location.create!( name: 'Highland', location_type: 'local authority' )

    visit '/'
    click_link 'Sign in'
    fill_in('user_email', with: 'test@localhost')
    fill_in('Password', with: 'password')
    click_button 'Sign in'

  end

  it 'sends a list of locations' do
    visit '/api/locations?q=me'
    json = JSON.parse(page.body)
    expect(page.status_code).to be 200
    expect(json.length).to eq(2)
  end

  it 'sends an empty list if no location matches' do
    visit '/api/locations?q=foobar'
    json = JSON.parse(page.body)
    expect(page.status_code).to be 200
    expect(json.length).to eq(0)
  end

  it 'sends an empty list if no query parameter sent' do
    visit '/api/locations'
    json = JSON.parse(page.body)
    expect(page.status_code).to be 200
    expect(json.length).to eq(0)
  end

  it 'does not show empty brackets when no location type is specified' do
    visit '/api/locations?q=engl'
    expect(page.status_code).to be 200
    responseObj = JSON.parse(page.body)
    expect(responseObj.length).to eq(1)
    expect(responseObj[0]).to eq("England")
  end


end
