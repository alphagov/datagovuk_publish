require 'rails_helper'

describe "managing datasets" do
  let(:land) { FactoryGirl.create(:organisation, name: 'land-registry', title: 'Land Registry') }
  let(:user) { FactoryGirl.create(:user, primary_organisation: land) }
  let(:price_paid_dataset) { FactoryGirl.create(:dataset, organisation: land, owner: user, name: 'price paid data', title: 'Price Paid data for all London Boroughs', summary: 'Price Paid Data tracks the residential property sales in England and Wales that are lodged with HM Land Registry for registration. ')}
  let(:searchable) { FactoryGirl.create(:dataset, organisation: land, owner: user, name: 'searchable', title: 'Find data here',summary: 'A fake dataset for search ')}

  before(:each) do
    user
    sign_in_user
    price_paid_dataset
    searchable
  end

  it "after login" do
    expect(page).to have_current_path '/tasks'

    # Don't expect any tables as creator_id not set on dataset
    click_link 'Manage datasets'
    expect(page).to have_content('No results found')
    expect(page).to have_selector(%(table), count: 0)

    # Expect to see the table with datasets in it.
    click_link 'Land Registry datasets'
    expect(page).to have_content('Price Paid data for all London Boroughs')
    expect(page).to have_selector(%(table), count: 1)
  end

  it "can do a search" do
    click_link 'Manage datasets'
    click_link 'Land Registry datasets'

    # expect 2 datasets to be displayed
    within('#dataset-list') do
      expect(page).to have_selector(%(th), count: 2)
    end

    fill_in('q', with: "find")
    click_button 'Search'

    # We expect only a single result now
    within('#dataset-list') do
      expect(page).to have_selector(%(th), count: 1)
    end

    click_link 'My datasets'
    expect(page).not_to have_content('Find data here')

    fill_in('q', with: "cats")
    click_button 'Search'
    # No results, no table.
    expect(page).to have_selector(%(th), count: 0)
  end

end
