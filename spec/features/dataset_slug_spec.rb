require "rails_helper"

describe 'dataset slug' do
  it "redirects a URL with an old slug to the URL with the latest slug" do
    url = "https://test.data.gov.uk/api/3/action/package_patch"
    stub_request(:any, url).to_return(status: 200)

    organisation = FactoryGirl.create(:organisation)
    user = FactoryGirl.create(:user, primary_organisation: organisation)
    dataset = FactoryGirl.create(:dataset,
                                 title: "foo",
                                 uuid: "1234",
                                 organisation: organisation,
                                 status: "published",
                                 links: [FactoryGirl.create(:link)],
                                 creator: user,
                                 owner: user)

    sign_in_user

    visit dataset_url(dataset)
    expect(current_path).to eq "/datasets/1234-foo"

    visit edit_dataset_url(dataset)
    fill_in 'dataset[title]', with: 'bar'
    click_button 'Save and continue'

    visit "/datasets/1234-foo"
    expect(current_path).to eq "/datasets/1234-bar"
  end
end

