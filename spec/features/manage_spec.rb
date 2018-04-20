require 'rails_helper'

describe "managing datasets" do
  let(:organisation) { FactoryGirl.create(:organisation) }
  let!(:user) { FactoryGirl.create(:user, primary_organisation: organisation) }
  let!(:dataset_1) { FactoryGirl.create(:dataset, title: "Cats per square mile", organisation: organisation) }
  let!(:dataset_2) { FactoryGirl.create(:dataset, title: "Dogs per square mile", organisation: organisation) }

  before(:each) do
    sign_in_user
  end

  it "after login" do
    expect(page).to have_current_path '/tasks'

    # Don't expect any tables as creator_id not set on dataset
    click_link 'Manage datasets'
    expect(page).to have_content('No results found')
    expect(page).to have_selector(%(table), count: 0)

    # Expect to see the table with datasets in it.
    click_link "#{organisation.title} datasets"
    expect(page).to have_content(dataset_1.title)
    expect(page).to have_selector(%(table), count: 1)
  end

  it "can do a search" do
    click_link 'Manage datasets'
    click_link "#{organisation.title} datasets"

    # expect 2 datasets to be displayed
    within('#dataset-list') do
      expect(page).to have_selector(%(th), count: 2)
    end

    fill_in('q', with: "#{dataset_1.title}")
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

  it "paginates datasets" do
    FactoryGirl.create(:dataset, organisation: organisation) # create a third dataset
    datasets_per_page = 2

    visit manage_organisation_path(per: datasets_per_page)
    within('#dataset-list') do
      expect(page).to have_selector(%(th), count: 2)
    end

    click_link '2'
    within('#dataset-list') do
      expect(page).to have_selector(%(th), count: 1)
    end
  end
end
