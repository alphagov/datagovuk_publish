require 'rails_helper'

describe DatasetsController, type: :controller do
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
    sign_in(user)

    dataset = FactoryGirl.create(:dataset,
                                  links: [FactoryGirl.create(:link)])

    url = "https://test.data.gov.uk/api/3/action/package_patch"

    stub_request(:any, url).to_return(status: 200)

    patch :update, params: { id: dataset.name, dataset: { title: "New title" } }
    dataset.reload

    expect(dataset.title).to eq("New title")

    expect(WebMock)
      .to have_requested(:post, url)
      .once
  end

  it "redirects to slugged URL" do
    user =  FactoryGirl.create(:user)
    sign_in(user)

    dataset = FactoryGirl.create(:dataset, links: [FactoryGirl.create(:link)])

    get :show, params: { id: dataset.id }

    expect(response).to redirect_to(dataset_url(dataset))
  end
end
