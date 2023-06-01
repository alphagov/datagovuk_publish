require "rails_helper"

describe "ckan package import" do
  subject { CKAN::V26::PackageImportWorker.new }

  let(:package_inspire) { JSON.parse(file_fixture("ckan/v26/package_show_inspire.json").read) }
  let(:package_create) { JSON.parse(file_fixture("ckan/v26/package_show_create.json").read) }
  let(:package_empty) { JSON.parse(file_fixture("ckan/v26/package_show_empty.json").read) }

  let(:package_empty_id) { package_empty["result"]["id"] }
  let(:package_create_id) { package_create["result"]["id"] }
  let(:package_inspire_id) { package_inspire["result"]["id"] }
  let(:datafile_create_id) { package_create["result"]["resources"][0]["id"] }

  before do
    create(:organisation, uuid: package_inspire["result"]["owner_org"])
    create(:organisation, uuid: package_create["result"]["owner_org"])
    create(:organisation, uuid: package_empty["result"]["owner_org"])

    stub_request(:get, "http://ckan/api/3/action/package_show")
      .with(query: { id: package_inspire_id })
      .to_return(body: package_inspire.to_json)

    stub_request(:get, "http://ckan/api/3/action/package_show")
      .with(query: { id: package_create_id })
      .to_return(body: package_create.to_json)

    stub_request(:get, "http://ckan/api/3/action/package_show")
      .with(query: { id: package_empty_id })
      .to_return(body: package_empty.to_json)
  end

  describe "govuk sidekiq" do
    it "can cope with retries after failure" do
      context = { "authenticated_user" => nil, "request_id" => nil }

      expect { subject.perform(package_create_id, context) }
        .to_not raise_error
    end
  end

  describe "dataset update" do
    it "creates a new dataset if it does not exist" do
      expect { subject.perform(package_create_id) }
        .to change { Dataset.count }.by(1)
    end

    it "updates an existing dataset if already exists" do
      dataset = Dataset.new(uuid: package_create_id, title: "")
      dataset.save!(validate: false)

      expect { subject.perform(package_create_id) }
        .to_not(change { Dataset.count })

      expect(dataset.reload.title).to eq package_create["result"]["title"]

      expect(dataset.reload.harvested?).to be(true)
    end
  end

  describe "inspire update" do
    it "creates an inspire dataset for inspire packages" do
      expect { subject.perform(package_inspire_id) }
        .to change { InspireDataset.count }.by(1)
    end

    it "updates an inspire dataset if it already exists" do
      dataset = Dataset.new(uuid: package_inspire_id, title: "")
      dataset.save!(validate: false)

      inspire_dataset = InspireDataset.new(dataset:)
      inspire_dataset.save!(validate: false)

      expect { subject.perform(package_inspire_id) }
        .to_not(change { InspireDataset.count })

      expect(inspire_dataset.reload.import_source).to eq "harvest"
    end

    it "removes an inspire dataset if it is not in the package" do
      create :dataset, :inspire, uuid: package_create_id

      expect { subject.perform(package_create_id) }
        .to change { InspireDataset.count }.by(-1)
    end
  end

  describe "link update" do
    it "creates a new link if it does not exist" do
      expect { subject.perform(package_create_id) }
        .to change { Link.count }.by(1)
    end

    it "updates a link if it already exists" do
      dataset = Dataset.new(uuid: package_create_id, title: "")
      dataset.save!(validate: false)

      datafile = Datafile.new(dataset:, uuid: datafile_create_id)
      datafile.save!(validate: false)

      expect { subject.perform(package_create_id) }
        .to_not(change { Link.count })

      expect(datafile.reload.name)
        .to eq package_create["result"]["resources"][0]["name"]
    end

    it "removes a link if it is not in the package" do
      create :dataset,
             uuid: package_empty_id,
             datafiles: (build_list :datafile, 1)

      expect { subject.perform(package_empty_id) }
        .to change { Link.count }.by(-1)
    end
  end

  describe "dataset publish" do
    before do
      subject.perform(package_create_id)
    end

    it "publishes a new dataset to elasticsearch" do
      dataset = Dataset.find_by(uuid: package_create_id)
      document = get_from_es(dataset.uuid)
      expect(document).to eq in_es_format(dataset.as_indexed_json)
    end

    it "publishes an existing dataset to elasticsearch" do
      dataset = Dataset.find_by(uuid: package_create_id)
      dataset.update!(title: "foo")

      dataset.publish
      expect(get_from_es(dataset.uuid)["title"]).to eq "foo"

      subject.perform(package_create_id)
      expect(get_from_es(dataset.uuid)["title"]).to_not eq "foo"
    end
  end
end
