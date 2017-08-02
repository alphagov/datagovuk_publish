require 'rails_helper'

describe "Organisations API" do
  before(:each) do
    org = Organisation.new
    org.name = 'land-registry'
    org.title = 'Land Registry'
    org.save!()
  end

  it 'sends a list of organisations' do
    visit '/api/organisations?q=land'
    json = JSON.parse(page.body)
    expect(page.status_code).to be 200
    expect(json.length).to eq(1)
  end

  it 'sends an empty list if no organisation matches' do
    visit '/api/organisations?q=foobar'
    json = JSON.parse(page.body)
    expect(page.status_code).to be 200
    expect(json.length).to eq(0)
  end

  it 'sends a full list if no query parameter sent' do
    visit '/api/organisations'
    json = JSON.parse(page.body)
    expect(page.status_code).to be 200
    expect(json.length).to eq(1)
  end


end
