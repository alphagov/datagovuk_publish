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
end
