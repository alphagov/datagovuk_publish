require "rails_helper"

describe "show datasets" do
  let(:land) { create(:organisation) }
  let(:user) { create(:user, primary_organisation: land) }
  let!(:dataset) { create :dataset, creator: user, organisation: land }

  before do
    sign_in_as(user)
  end

  it "should disable editing for harvested datasets" do
    dataset.update(harvested: true)
    click_link 'Manage datasets'

    expect(page).to have_content(dataset.title)
    expect(page).not_to have_content("Add Data")
    expect(page).not_to have_content("Edit")
  end

  it "should provide links to edit a manual dataset" do
    click_link 'Manage datasets'
    expect(page).to have_content(dataset.title)
    expect(page).to have_content("Add Data")
    expect(page).to have_content("Edit")
  end
end
