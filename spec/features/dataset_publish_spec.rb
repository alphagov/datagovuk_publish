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

    dataset.reload.attributes.each do |key, value|
      expect(document[key.to_s]).to eq in_es_format(value)
    end

    expect(document["topic"]).to eq in_es_format(dataset.topic)
    expect(document["organisation"]).to eq in_es_format(dataset.organisation)
    expect(document["docs"]).to eq in_es_format(dataset.docs)
    expect(document["datafiles"]).to eq in_es_format(dataset.datafiles)
    expect(document["inspire_dataset"]).to eq in_es_format(dataset.inspire_dataset)

    expect(document["public_updated_at"]).to eq in_es_format(dataset.datafiles.last.updated_at)
    expect(document["released"]).to be_truthy
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

  it "should be able to unpublish a dataset" do
    visit dataset_url(dataset.uuid, dataset.name)
    click_link 'Delete this dataset'
    click_link "Yes, delete this dataset"
    expect { get_from_es(dataset.id) }.to raise_error(/404/)
  end
end
