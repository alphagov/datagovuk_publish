require 'rails_helper'

describe 'ckan package sync' do
  subject { CKAN::V26::PackageSyncWorker.new }

  let(:search_dataset_v26_p1) { JSON.parse(file_fixture("ckan/v26/search_dataset_p1.json").read) }
  let(:search_dataset_v26_p2) { JSON.parse(file_fixture("ckan/v26/search_dataset_p2.json").read) }
  let(:show_dataset_v26_create) { JSON.parse(file_fixture("ckan/v26/show_dataset_create.json").read) }
  let(:show_dataset_v26_update) { JSON.parse(file_fixture("ckan/v26/show_dataset_update.json").read) }

  let(:package_for_update) { search_dataset_v26_p1["results"][0] }
  let(:package_not_for_update) { search_dataset_v26_p1["results"][1] }
  let(:package_for_create) { search_dataset_v26_p1["results"][2] }

  let!(:dataset_to_delete) { create :dataset, legacy_name: "dataset_to_delete" }
  let!(:dataset_to_ignore) { create :dataset, legacy_name: nil }

  let!(:dataset_to_update) do
    create :dataset, legacy_name: "dataset_to_update",
                     uuid: package_for_update["id"],
                     updated_at: 5.years.ago
  end

  let!(:dataset_not_to_update) do
    create :dataset, legacy_name: "dataset_not_to_update",
                     uuid: package_not_for_update["id"],
                     updated_at: Time.now
  end

  before do
    create(:organisation, uuid: "21f3491f-5b0f-4395-8bb9-990f9cc4d274")
    create(:organisation, uuid: "d3bb54b5-4289-4ff9-9546-ff95442643fc")

    stub_request(:get, "http://ckan/api/3/search/dataset")
      .with(query: { fl: "id,metadata_modified", start: 0, rows: 1000 })
      .to_return(body: search_dataset_v26_p1.to_json)

    stub_request(:get, "http://ckan/api/3/search/dataset")
      .with(query: { fl: "id,metadata_modified", start: 3, rows: 1000 })
      .to_return(body: search_dataset_v26_p2.to_json)

    stub_request(:get, "http://ckan/api/3/action/package_show")
      .with(query: { id: "7509bbb5-ce6a-4801-8d77-b72c58d46180" })
      .to_return(body: show_dataset_v26_update.to_json)

    stub_request(:get, "http://ckan/api/3/action/package_show")
      .with(query: { id: "bca22660-dccc-4a37-9cfe-6bc2c0739cff" })
      .to_return(body: show_dataset_v26_create.to_json)
  end

  it 'creates new datasets when they appear in ckan' do
    subject.perform
    expect(Dataset.pluck(:uuid)).to include package_for_create["id"]
  end

  it 'updates existing datasets when they change in ckan' do
    expect { subject.perform }
      .to change { dataset_to_update.reload.updated_at }
      .to(Time.parse(show_dataset_v26_update["result"]["metadata_modified"]))
  end

  it 'preserves existing datasets when they do not change in ckan' do
    expect { subject.perform }
      .to_not(change { dataset_not_to_update.reload.updated_at })
  end

  it 'preserves existing datasets when they do not come from ckan' do
    expect { subject.perform }
      .to_not(change { dataset_to_ignore.reload.updated_at })
  end

  it 'deletes datasets when they disappear from ckan' do
    dataset_to_delete.publish
    subject.perform

    expect(Dataset.all).to_not include dataset_to_delete
    expect { get_from_es(dataset_to_delete.uuid) }.to raise_error(/404/)
  end
end
