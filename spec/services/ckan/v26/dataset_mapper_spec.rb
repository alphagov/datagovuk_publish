require 'rails_helper'

describe CKAN::V26::DatasetMapper do
  let(:package) { build :ckan_v26_package }

  let!(:organisation) { create :organisation, uuid: package.get("owner_org") }
  let!(:topic) { create :topic, name: 'environment-and-fisheries' }

  describe '#call' do
    it 'returns the mapped dataset attributes for a package' do
      attributes = subject.call(package)

      expect(attributes[:title]).to eq package.get("title")
      expect(attributes[:summary]).to eq package.get("notes")
      expect(attributes[:legacy_name]).to eq package.get("name")
      expect(attributes[:organisation_id]).to eq organisation.id
      expect(attributes[:created_at]).to eq package.get("metadata_created")
      expect(attributes[:updated_at]).to eq package.get("metadata_modified")
      expect(attributes[:harvested]).to be_falsey
      expect(attributes[:contact_name]).to eq package.get("contact-name")
      expect(attributes[:contact_email]).to eq package.get("contact-email")
      expect(attributes[:foi_name]).to eq package.get("foi-name")
      expect(attributes[:foi_email]).to eq package.get("foi-email")
      expect(attributes[:foi_web]).to eq package.get("foi-web")
      expect(attributes[:location1]).to eq "England, Scotland, Wales"
      expect(attributes[:licence_code]).to eq package.get("license_id")
      expect(attributes[:licence_title]).to eq Licence.lookup("uk-ogl").title
      expect(attributes[:licence_url]).to eq Licence.lookup("uk-ogl").url
      expect(attributes[:licence_custom]).to be_nil
      expect(attributes[:topic_id]).to eq topic.id
      expect(attributes[:status]).to eq "published"
    end

    it 'copes when a topic cannot be found for the package' do
      topic.destroy
      attributes = subject.call(package)
      expect(attributes[:topic_id]).to be_nil
    end

    it 'copes when an organisation cannot be found for the package' do
      organisation.destroy
      attributes = subject.call(package)
      expect(attributes[:organisation_id]).to be_nil
    end

    it 'accurately determines when a dataset is harvested' do
      package = build :ckan_v26_package, :harvested
      attributes = subject.call(package)
      expect(attributes[:harvested]).to be_truthy
    end

    it 'uses a default string when the package has no notes' do
      package = build :ckan_v26_package, notes: ""
      attributes = subject.call(package)
      expect(attributes[:summary]).to eq "No description provided"
    end
  end
end
