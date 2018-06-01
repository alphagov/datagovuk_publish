require 'rails_helper'

describe 'ckan sync' do
  subject { CKANSyncWorker.new }
  let(:search_dataset_v26_p1) { JSON.parse(file_fixture("search_dataset_v26_p1.json").read) }
  let(:search_dataset_v26_p2) { JSON.parse(file_fixture("search_dataset_v26_p2.json").read) }

  let(:package_for_update) { search_dataset_v26_p1["results"][0] }
  let(:package_not_for_update) { search_dataset_v26_p1["results"][1] }
  let(:package_for_create) { search_dataset_v26_p1["results"][2] }

  let!(:dataset_to_delete) { create :dataset, legacy_name: "dataset_to_delete" }
  let!(:dataset_to_ignore) { create :dataset, legacy_name: nil }

  let!(:dataset_to_update) do
    create :dataset, legacy_name: "dataset_to_update",
                     uuid: package_for_update["id"],
                     last_updated_at: 5.years.ago
  end

  let!(:dataset_not_to_update) do
    create :dataset, legacy_name: "dataset_not_to_update",
                     uuid: package_not_for_update["id"],
                     last_updated_at: Time.now
  end

  before do
    stub_request(:get, "http://ckan/api/3/search/dataset")
      .with(query: { fl: "id,metadata_modified", start: 0, rows: 1000 })
      .to_return(body: search_dataset_v26_p1.to_json)

    stub_request(:get, "http://ckan/api/3/search/dataset")
      .with(query: { fl: "id,metadata_modified", start: 3, rows: 1000 })
      .to_return(body: search_dataset_v26_p2.to_json)
  end

  it 'creates new datasets when they appear in ckan' do
    subject.perform
    expect(Dataset.pluck(:uuid)).to include package_for_create["id"]
  end

  it 'updates existing datasets when they change in ckan' do
    expect { subject.perform }
      .to change { dataset_to_update.reload.last_updated_at }
      .to(Time.parse(package_for_update["metadata_modified"]))
  end

  it 'preserves existing datasets when they do not change in ckan' do
    expect { subject.perform }
      .to_not(change { dataset_not_to_update.reload.last_updated_at })
  end

  it 'preserves existing datasets when they do not come from ckan' do
    expect { subject.perform }
      .to_not(change { dataset_to_ignore.reload.updated_at })
  end

  it 'deletes datasets when they disappear from ckan' do
    subject.perform
    expect(Dataset.all).to_not include dataset_to_delete
  end
end
