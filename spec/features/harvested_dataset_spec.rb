require "rails_helper"

describe "Harvested datasets" do
  let(:land) { FactoryGirl.create(:organisation) }
  let(:user) { FactoryGirl.create(:user, primary_organisation: land) }
  let!(:harvested_dataset) do
    FactoryGirl.create(:dataset,
                       organisation: land,
                       harvested: true,
                       datafiles: [FactoryGirl.create(:datafile)],
                       creator: user,
                       owner: user)
  end

  it "should be readonly (no add/edit buttons appear)" do
    sign_in_user
    click_link 'Manage datasets'

    expect(page).to have_content(harvested_dataset.title)
    expect(page).not_to have_content("Add Data")
    expect(page).not_to have_content("Edit")
  end
end
