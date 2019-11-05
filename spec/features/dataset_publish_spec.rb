require "rails_helper"

describe "publishing datasets" do
  let(:land) { create(:organisation) }
  let(:user) { create(:user, primary_organisation: land) }

  let!(:dataset) do
    create(:dataset, :with_datafile, :with_doc, creator: user, organisation: land)
  end

  before do
    sign_in_as(user)
  end

  it "should be able to publish a draft dataset" do
    visit dataset_url(dataset.uuid, dataset.name)
    click_button "Publish"

    document = get_from_es(dataset.uuid)
    expect(document).to eq in_es_format(dataset.reload.as_indexed_json)
  end

  it "should be able to update a published dataset" do
    visit dataset_url(dataset.uuid, dataset.name)

    click_change(:title)
    fill_in "dataset[title]", with: "a new title"
    click_button "Save and continue"

    click_button "Publish"
    document = get_from_es(dataset.uuid)
    expect(document["title"]).to eq "a new title"
  end

  it "correctly determines when a dataset has been released" do
    dataset.links.destroy_all
    visit dataset_url(dataset.uuid, dataset.name)
    click_button "Publish"

    document = get_from_es(dataset.uuid)
    expect(document["released"]).to be_falsey
  end

  it "correctly determines the public_updated_at for a dataset" do
    dataset.links.destroy_all
    visit dataset_url(dataset.uuid, dataset.name)
    click_button "Publish"

    document = get_from_es(dataset.uuid)
    expect(document["public_updated_at"]).to eq in_es_format(dataset.reload.updated_at)
  end

  it "determines the public_updated_at for inspire datasets" do
    dataset = create :dataset, :inspire, creator: user, organisation: land
    visit dataset_url(dataset.uuid, dataset.name)
    click_button "Publish"

    document = get_from_es(dataset.uuid)
    date = JSON.parse(dataset.inspire_dataset.dataset_reference_date).first["value"]
    expect(document["public_updated_at"]).to eq in_es_format(date)
  end

  it "determines the public_updated_at with datafiles" do
    visit dataset_url(dataset.uuid, dataset.name)
    click_button "Publish"

    document = get_from_es(dataset.uuid)
    expect(document["public_updated_at"]).to eq in_es_format(dataset.datafiles.first.updated_at)
  end

  it "determines the public_updated_at for inspire datasets with datafiles" do
    dataset = create :dataset, :with_datafile, :inspire, creator: user, organisation: land
    visit dataset_url(dataset.uuid, dataset.name)
    click_button "Publish"

    document = get_from_es(dataset.uuid)
    expect(document["public_updated_at"]).to eq in_es_format(dataset.datafiles.first.updated_at)
  end

  it "copes with invalid inspire dataset reference dates" do
    dataset = create :dataset, inspire_dataset: (build :inspire_dataset, :invalid),
      creator: user, organisation: land

    visit dataset_url(dataset.uuid, dataset.name)
    click_button "Publish"

    document = get_from_es(dataset.uuid)
    expect(document["public_updated_at"]).to eq in_es_format(dataset.reload.updated_at)
  end
end
