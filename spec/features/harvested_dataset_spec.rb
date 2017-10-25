require "rails_helper"

describe "Harvested datasets" do
  let(:land) { FactoryGirl.create(:organisation) }
  let(:user) { FactoryGirl.create(:user, primary_organisation: land) }

  it "should be readonly (no add/edit buttons appear)" do
    stub_request(:any, /test.data.gov.uk/).to_return(status: 200)
    harvested_dataset = FactoryGirl.create(:dataset,
                                           organisation: land,
                                           harvested: true,
                                           links: [FactoryGirl.create(:link)],
                                           creator: user,
                                           owner: user)

    user
    sign_in_user
    click_link 'Manage datasets'

    expect(page).to have_content(harvested_dataset.title)
    expect(page).not_to have_content("Add Data")
    expect(page).not_to have_content("Edit")
  end
end
