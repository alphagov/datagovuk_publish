require "rails_helper"

describe "publishing datasets" do
  let(:land) { create(:organisation) }
  let(:user) { create(:user, primary_organisation: land) }

  let!(:dataset) do
    create :dataset, :with_datafile, :with_doc,
                     creator: user, organisation: land
  end

  before do
    sign_in_as(user)
  end

  it "should be able to publish a draft dataset" do
    visit dataset_url(dataset.uuid, dataset.name)
    click_button 'Publish'

    document = get_from_es(dataset.id)
    expect(document).to eq in_es_format(dataset.reload.as_indexed_json)
  end

  it "should be able to update a published dataset" do
    visit dataset_url(dataset.uuid, dataset.name)

    click_change(:title)
    fill_in 'dataset[title]', with: 'a new title'
    click_button 'Save and continue'

    click_button 'Publish'
    document = get_from_es(dataset.id)
    expect(document["title"]).to eq 'a new title'
  end

  it 'correctly determines when a dataset has been released' do
    dataset.links.destroy_all
    visit dataset_url(dataset.uuid, dataset.name)
    click_button 'Publish'

    document = get_from_es(dataset.id)
    expect(document["released"]).to be_falsey
  end

  it 'correctly determines the public_updated_at for a dataset' do
    dataset.links.destroy_all
    visit dataset_url(dataset.uuid, dataset.name)
    click_button 'Publish'

    document = get_from_es(dataset.id)
    expect(document["public_updated_at"]).to eq in_es_format(dataset.reload.updated_at)
  end
end
