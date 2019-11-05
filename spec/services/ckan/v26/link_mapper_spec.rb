require "rails_helper"

describe CKAN::V26::LinkMapper do
  let(:dataset) { create :dataset }
  let(:resource) { build :ckan_v26_resource }

  describe "#call" do
    it "returns the mapped link attributes for a resource" do
      attributes = subject.call(resource, dataset)

      expect(attributes[:url]).to eq resource.get("url")
      expect(attributes[:format]).to eq resource.get("format")
      expect(attributes[:name]).to eq resource.get("name")
      expect(attributes[:created_at]).to eq resource.get("created")
      expect(attributes[:updated_at]).to eq resource.get("created")
      expect(attributes[:type]).to eq "Datafile"
    end

    it "correctly distinguishes between datafiles and docs" do
      resource = build :ckan_v26_resource, resource_type: "documentation"
      attributes = subject.call(resource, dataset)
      expect(attributes[:type]).to eq "Doc"
    end

    it "uses the resource description if there is not name" do
      resource = build :ckan_v26_resource, name: ""
      attributes = subject.call(resource, dataset)
      expect(attributes[:name]).to eq resource.get("description")
    end

    it "uses a default name if the resource has no name/description" do
      resource = build :ckan_v26_resource, name: "", description: ""
      attributes = subject.call(resource, dataset)
      expect(attributes[:name]).to eq "No name specified"
    end

    it "uses the dataset creation time if the resource has none" do
      resource = build :ckan_v26_resource, created: ""
      attributes = subject.call(resource, dataset)
      expect(attributes[:created_at]).to eq dataset.created_at
      expect(attributes[:updated_at]).to eq dataset.created_at
    end
  end
end
