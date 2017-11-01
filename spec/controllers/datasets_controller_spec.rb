require 'rails_helper'

describe DatasetsController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in(user)
  end

  it "prevents harvested datasets from being updated through the user interface" do
    dataset = FactoryGirl.create(:dataset,
                                 harvested: true)

    patch :update, params: { uuid: dataset.uuid, name: dataset.name, dataset: { title: "New title" } }

    dataset.valid?

    expect(dataset.errors[:base]).to include("Harvested datasets cannot be modified.")
  end

  it "updates legacy when a dataset is updated" do
    stub_request(:post, legacy_dataset_update_endpoint).to_return(status: 200)

    published_dataset = FactoryGirl.create(:dataset,
                                            links: [FactoryGirl.create(:link)],
                                            status: "published")

    post :publish, params: { uuid: published_dataset.uuid, name: published_dataset.name }

    legacy_dataset = Legacy::Dataset.new(published_dataset.reload)

    expect(WebMock)
      .to have_requested(:post, legacy_dataset_update_endpoint)
      .with(body: legacy_dataset.payload)
  end

  it "redirects to slugged URL" do
    organisation = FactoryGirl.create(:organisation, users: [user])
    dataset = FactoryGirl.create(:dataset,
                                 name: "legit-name",
                                 organisation: organisation,
                                 links: [FactoryGirl.create(:link)])

    get :show, params: { uuid: dataset.uuid, name: "absolute-nonsense-name" }

    expect(response).to redirect_to(dataset_url(dataset.uuid, dataset.name))
  end

  it "returns '503 forbidden' error if a user is not allowed to view the requested dataset" do
    organisation = FactoryGirl.create(:organisation, users: [user])

    another_organisation = FactoryGirl.create(:organisation)

    allowed_dataset = FactoryGirl.create(:dataset,
                                 organisation: organisation,
                                 links: [FactoryGirl.create(:link)])

    forbidden_dataset = FactoryGirl.create(:dataset,
                                 organisation: another_organisation,
                                 links: [FactoryGirl.create(:link)])

    get :show, params: { uuid: forbidden_dataset.uuid, name: forbidden_dataset.name }

    expect(response).to have_http_status(403)
  end

  it "returns '503 forbidden' error if a user is not allowed to update the requested dataset" do
    organisation = FactoryGirl.create(:organisation, users: [user])

    another_organisation = FactoryGirl.create(:organisation)

    allowed_dataset = FactoryGirl.create(:dataset,
                                 organisation: organisation,
                                 links: [FactoryGirl.create(:link)])

    forbidden_dataset = FactoryGirl.create(:dataset,
                                 organisation: another_organisation,
                                 links: [FactoryGirl.create(:link)])

    get :edit, params: { uuid: forbidden_dataset.uuid, name: forbidden_dataset.name }

    expect(response).to have_http_status(403)
  end
end
