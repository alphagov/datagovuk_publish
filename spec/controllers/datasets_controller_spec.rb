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

  it "updates legacy when an existing dataset is published" do
    stub_request(:post, legacy_dataset_update_endpoint).to_return(status: 200)
    stub_request(:post, legacy_datafile_update_endpoint).to_return(status: 200)

    published_dataset = FactoryGirl.create(:dataset,
                                            links: [FactoryGirl.create(:link)],
                                            status: "published",
                                            published_date: Time.now)

    post :publish, params: { uuid: published_dataset.uuid, name: published_dataset.name }

    legacy_dataset = Legacy::Dataset.new(published_dataset)

    expect(WebMock)
      .to have_requested(:post, legacy_dataset_update_endpoint)
      .with(body: legacy_dataset.update_payload)
  end

  it "creates a dataset on legacy when a newly created dataset is published" do
    ckan_response = { result: {id: "123abc"} }.to_json
    stub_request(:post, legacy_dataset_create_endpoint)
      .to_return( body: ckan_response,
                 status: 201 )
    dataset = FactoryGirl.create(:dataset,
                                links: [FactoryGirl.create(:link)])

    post :publish, params: { uuid: dataset.uuid, name: dataset.name }

    legacy_dataset = Legacy::Dataset.new(dataset)

    expect(WebMock)
      .to have_requested(:post, legacy_dataset_create_endpoint)
      .with(body: legacy_dataset.create_payload)
    expect(dataset.reload.ckan_uuid).to eq "123abc"
  end

    it "updates legacy if an existing datafile is updated after last dataset publication" do
      allow(PublishingWorker).to receive(:perform_async).and_return true

      stub_request(:post, legacy_dataset_update_endpoint).to_return(status: 200)
      stub_request(:post, legacy_datafile_update_endpoint).to_return(status: 200)

      creation_date = 1.week.ago
      publication_date = 1.day.ago

      dataset = FactoryGirl.build(:dataset,
                                   created_at: creation_date,
                                   updated_at: creation_date
                                 )
      dataset.save

      datafile_1 = FactoryGirl.build(:link,
                                     name: 'datafile_1',
                                     created_at: creation_date,
                                     updated_at: creation_date,
                                     dataset: dataset)
      datafile_1.save

      datafile_2 = FactoryGirl.build(:link,
                                     name: 'datafile_2',
                                     created_at: creation_date,
                                     updated_at: creation_date,
                                     dataset: dataset)
      datafile_2.save

      dataset.update(published_date: publication_date,
                     last_published_at: publication_date,
                      status: 'published')

      datafile_1.update(name: 'new name')

      dataset.publish!

      expect(WebMock)
        .to have_requested(:post, legacy_datafile_update_endpoint)
        .with(body: Legacy::Datafile.new(datafile_1).payload)
        .once

      expect(WebMock)
        .to_not have_requested(:post, legacy_datafile_update_endpoint)
        .with(body: Legacy::Datafile.new(datafile_2).payload)
        .once
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
