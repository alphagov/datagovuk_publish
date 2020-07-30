require "rails_helper"

describe "ckan organisation import" do
  subject { CKAN::V26::CKANOrgImportWorker.new }

  let(:organization_show) { JSON.parse(file_fixture("ckan/v26/organization_show_create.json").read) }
  let(:organisation_id) { organization_show["result"]["name"] }

  before do
    stub_request(:get, "http://ckan/api/3/action/organization_show")
      .with(query: { id: organisation_id })
      .to_return(body: organization_show.to_json)
  end

  describe "govuk sidekiq" do
    it "can cope with retries after failure" do
      context = { "authenticated_user" => nil, "request_id" => nil }

      expect { subject.perform(organisation_id, context) }
        .to_not raise_error
    end
  end

  describe "organisation update" do
    it "creates new organisations when they appear in ckan" do
      subject.perform(organisation_id)
      expect(Organisation.pluck(:name)).to include organisation_id
    end

    it "updates existing organisations when they change in ckan" do
      organisation = create :organisation, name: organisation_id

      expect { subject.perform(organisation_id) }
        .to(change { organisation.reload.updated_at })
    end

    it "does not update organisations if they are unchanged" do
      subject.perform(organisation_id)
      organisation = Organisation.find_by(name: organisation_id)
      organisation.update!(updated_at: 5.years.ago)

      expect { subject.perform(organisation_id) }
        .to_not(change { organisation.reload.updated_at })
    end
  end

  describe "dataset publish" do
    let(:organisation) { create :organisation, name: organisation_id }
    let!(:dataset_to_republish) { create :dataset, organisation: organisation }
    let!(:dataset_not_to_publish) { create :dataset, organisation: organisation, status: "draft" }

    before do
      subject.perform(organisation_id)
    end

    it "publishes datasets when their organisation is updated" do
      document = get_from_es(dataset_to_republish.uuid)
      expected = dataset_to_republish.reload.as_indexed_json
      expect(document).to eq in_es_format(expected)
    end

    it "does not publish datasets when they have not been published" do
      expect { get_from_es(dataset_not_to_publish.uuid) }.to raise_error(/404/)
    end

    it "does not publish datasets when the organisation is unchanged" do
      dataset_to_republish.update!(title: "Old")
      dataset_to_republish.publish

      subject.perform(organisation_id)

      document = get_from_es(dataset_to_republish.uuid)
      expected = dataset_to_republish.reload.as_indexed_json
      expect(document).to_not eq in_es_format(expected)
    end
  end
end
