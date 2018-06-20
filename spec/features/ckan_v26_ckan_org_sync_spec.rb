require 'rails_helper'

describe 'ckan organisation sync' do
  subject { CKAN::V26::CKANOrgSyncWorker.new }

  let(:organization_list) { JSON.parse(file_fixture("ckan/v26/organization_list.json").read) }
  let(:organization_show_create) { JSON.parse(file_fixture("ckan/v26/organization_show_create.json").read) }
  let(:organization_show_update) { JSON.parse(file_fixture("ckan/v26/organization_show_update.json").read) }

  let(:organisation_to_create_id) { organization_list["result"][0] }
  let(:organisation_to_update_id) { organization_list["result"][1] }

  let!(:organisation_to_delete) { create :organisation, name: "organisation_to_delete", govuk_content_id: nil }
  let!(:organisation_to_ignore) { create :organisation, name: "organisation_to_ignore" }
  let!(:organisation_to_update) { create :organisation, name: organisation_to_update_id }

  let!(:dataset_to_unpublish) { create :dataset, organisation: organisation_to_delete }
  let!(:dataset_not_to_unpublish) { create :dataset, organisation: organisation_to_delete }

  before do
    dataset_to_unpublish.publish

    stub_request(:get, "http://ckan/api/3/action/organization_list")
      .to_return(body: organization_list.to_json)

    stub_request(:get, "http://ckan/api/3/action/organization_show")
      .with(query: { id: organisation_to_create_id })
      .to_return(body: organization_show_create.to_json)

    stub_request(:get, "http://ckan/api/3/action/organization_show")
      .with(query: { id: organisation_to_update_id })
      .to_return(body: organization_show_update.to_json)
  end

  it 'creates new organisations when they appear in ckan' do
    subject.perform
    expect(Organisation.pluck(:name)).to include organisation_to_create_id
  end

  it 'updates existing organisations when they change in ckan' do
    expect { subject.perform }
      .to(change { organisation_to_update.reload.updated_at })
  end

  it 'does not update organisations if they are unchanged' do
    subject.perform
    organisation_to_update.update(updated_at: 5.years.ago)

    expect { subject.perform }
      .to_not(change { organisation_to_update.reload.updated_at })
  end

  it 'deletes organisations when they disappear from ckan' do
    subject.perform
    expect(Organisation.all).to_not include organisation_to_delete
    expect(Dataset.count).to be_zero
    expect { get_from_es(dataset_to_unpublish.uuid) }.to raise_error(/404/)
  end

  it 'does not delete organisations with a govuk_content_id' do
    subject.perform
    expect(Organisation.all).to include organisation_to_ignore
  end
end
