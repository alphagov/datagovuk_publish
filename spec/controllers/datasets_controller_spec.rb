require 'rails_helper'

describe DatasetsController, type: :controller do

  before :each do
    url = "https://test.data.gov.uk/api/3/action/package_patch"
    stub_request(:any, url).to_return(status: 200)
  end

  it "prevents harvested datasets from being updated through the user interface" do
    user = FactoryGirl.create(:user)
    sign_in(user)

    dataset = FactoryGirl.create(:dataset,
                                 harvested: true,
                                 links: [FactoryGirl.create(:link)])

    patch :update, params: { id: dataset.name, dataset: { title: "New title" } }

    dataset.valid?

    expect(dataset.errors[:base]).to include("Harvested datasets cannot be modified.")
  end

  it "updates legacy when a dataset is updated" do
    user =  FactoryGirl.create(:user)
    dataset = FactoryGirl.create(:dataset, links: [FactoryGirl.create(:link)])

    sign_in(user)

    patch :update, params: { id: dataset.name, dataset: { title: "New title" } }

    dataset.reload

    expect(dataset.title).to eq("New title")

    expect(WebMock)
      .to have_requested(:post, 'https://test.data.gov.uk/api/3/action/package_patch')
      .once
  end

  it "redirects to slugged URL" do
    user =  FactoryGirl.create(:user)
    organisation = FactoryGirl.create(:organisation, users: [user])
    dataset = FactoryGirl.create(:dataset,
                                 organisation: organisation,
                                 links: [FactoryGirl.create(:link)])

    sign_in(user)

    get :show, params: { id: dataset.id }

    expect(response).to redirect_to(dataset_url(dataset))
  end

  it "returns '503 forbidden' error if a user is not allowed to view the requested dataset" do
    user = FactoryGirl.create(:user)
    organisation = FactoryGirl.create(:organisation, users: [user])

    another_organisation = FactoryGirl.create(:organisation)

    allowed_dataset = FactoryGirl.create(:dataset,
                                 organisation: organisation,
                                 links: [FactoryGirl.create(:link)])

    forbidden_dataset = FactoryGirl.create(:dataset,
                                 organisation: another_organisation,
                                 links: [FactoryGirl.create(:link)])

    sign_in(user)

    get :show, params: { id: forbidden_dataset.id }

    expect(response).to have_http_status(403)
  end

  it "returns '503 forbidden' error if a user is not allowed to update the requested dataset" do
    user = FactoryGirl.create(:user)
    organisation = FactoryGirl.create(:organisation, users: [user])

    another_organisation = FactoryGirl.create(:organisation)

    allowed_dataset = FactoryGirl.create(:dataset,
                                 organisation: organisation,
                                 links: [FactoryGirl.create(:link)])

    forbidden_dataset = FactoryGirl.create(:dataset,
                                 organisation: another_organisation,
                                 links: [FactoryGirl.create(:link)])

    sign_in(user)

    get :edit, params: { id: forbidden_dataset.id }

    expect(response).to have_http_status(403)
  end
end
