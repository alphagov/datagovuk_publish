require "rails_helper"

describe CKAN::V26::OrganisationMapper do
  let(:ckan_org) { build :ckan_v26_ckan_org }
  let!(:organisation) { create :organisation, name: ckan_org.get("name") }

  describe "#call" do
    it "returns the mapped organization attributes for a CKAN org" do
      attributes = subject.call(ckan_org)

      expect(attributes[:uuid]).to eq ckan_org.get("id")
      expect(attributes[:title]).to eq ckan_org.get("title")
      expect(attributes[:contact_name]).to eq ckan_org.get("contact-name")
      expect(attributes[:contact_email]).to eq ckan_org.get("contact-email")
      expect(attributes[:foi_name]).to eq ckan_org.get("foi-name")
      expect(attributes[:foi_email]).to eq ckan_org.get("foi-email")
      expect(attributes[:foi_web]).to eq ckan_org.get("foi-web")
      expect(attributes[:category]).to eq ckan_org.get("category")
    end
  end
end
