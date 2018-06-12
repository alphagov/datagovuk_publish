require 'rails_helper'

describe 'ckan import' do
  subject { CKAN::V26::ImportWorker.new }

  let(:empty_package_id) { "8fda2162-dcd6-4fb3-9835-c85c046ff229" }
  let(:create_package_id) { "bca22660-dccc-4a37-9cfe-6bc2c0739cff" }
  let(:inspire_package_id) { "cf494c44-05cd-4060-a029-35937970c9c6" }
  let(:create_datafile_id) { "113b39be-e04c-4089-a8ca-a671d9b5076c" }

  let(:package_v26_inspire) { JSON.parse(file_fixture("ckan/v26/show_dataset_inspire.json").read) }
  let(:package_v26_create) { JSON.parse(file_fixture("ckan/v26/show_dataset_create.json").read) }
  let(:package_v26_empty) { JSON.parse(file_fixture("ckan/v26/show_dataset_empty.json").read) }

  before do
    create(:organisation, uuid: "11c51f05-a8bf-4f58-9b95-7ab55f9546d7")
    create(:organisation, uuid: "21f3491f-5b0f-4395-8bb9-990f9cc4d274")
    create(:organisation, uuid: "83cbb68a-814b-4fb5-a7dd-c9ec6c5fe455")

    stub_request(:get, "http://ckan/api/3/action/package_show")
      .with(query: { id: inspire_package_id })
      .to_return(body: package_v26_inspire.to_json)

    stub_request(:get, "http://ckan/api/3/action/package_show")
      .with(query: { id: create_package_id })
      .to_return(body: package_v26_create.to_json)

    stub_request(:get, "http://ckan/api/3/action/package_show")
      .with(query: { id: empty_package_id })
      .to_return(body: package_v26_empty.to_json)
  end

  describe 'govuk sidekiq' do
    it 'can cope with retries after failure' do
      context = { "authenticated_user" => nil, "request_id" => nil }

      expect { subject.perform(create_package_id, context) }
        .to_not raise_error
    end
  end

  describe 'dataset update' do
    it 'creates a new dataset if it does not exist' do
      expect { subject.perform(create_package_id) }
        .to change { Dataset.count }.by(1)
    end

    it 'updates an existing dataset if already exists' do
      create :dataset, uuid: create_package_id

      expect { subject.perform(create_package_id) }
        .to_not(change { Dataset.count })
    end
  end

  describe 'inspire update' do
    it 'creates an inspire dataset for inspire packages' do
      expect { subject.perform(inspire_package_id) }
        .to change { InspireDataset.count }.by(1)
    end

    it 'updates an inspire dataset if it already exists' do
      create :dataset, uuid: inspire_package_id,
                       inspire_dataset: (build :inspire_dataset)

      expect { subject.perform(inspire_package_id) }
        .to_not(change { InspireDataset.count })
    end

    it 'removes an inspire dataset if it is not in the package' do
      create :dataset, uuid: create_package_id,
                       inspire_dataset: (build :inspire_dataset)

      expect { subject.perform(create_package_id) }
        .to change { InspireDataset.count }.by(-1)
    end
  end

  describe 'link update' do
    it 'creates a new link if it does not exist' do
      expect { subject.perform(create_package_id) }
        .to change { Link.count }.by(1)
    end

    it 'updates a link if it already exists' do
      datafile = create :datafile, uuid: create_datafile_id
      create :dataset, uuid: create_package_id, datafiles: [datafile]

      expect { subject.perform(create_package_id) }
        .to_not(change { Link.count })
    end

    it 'removes a link if it is not in the package' do
      create :dataset, uuid: empty_package_id,
                       datafiles: (build_list :datafile, 1)

      expect { subject.perform(empty_package_id) }
        .to change { Link.count }.by(-1)
    end
  end

  describe 'dataset publish' do
    before do
      subject.perform(create_package_id)
    end

    it 'publishes a new dataset to elasticsearch' do
      dataset = Dataset.find_by(uuid: create_package_id)
      document = get_from_es(dataset.uuid)
      expect(document).to eq in_es_format(dataset.as_indexed_json)
    end

    it 'publishes an existing dataset to elasticsearch' do
      dataset = Dataset.find_by(uuid: create_package_id)
      dataset.update(title: "foo")

      dataset.publish
      expect(get_from_es(dataset.uuid)["title"]).to eq "foo"

      subject.perform(create_package_id)
      expect(get_from_es(dataset.uuid)["title"]).to_not eq "foo"
    end
  end
end
