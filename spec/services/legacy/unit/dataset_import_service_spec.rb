require 'rails_helper'

describe Legacy::DatasetImportService do
  let(:legacy_dataset) do
      file_path = Rails.root.join('spec', 'fixtures', 'legacy_dataset.json')
      legacy_dataset_json = File.read(file_path)
      JSON.parse(legacy_dataset_json)["result"].with_indifferent_access
  end

  let(:orgs_cache) do
    { legacy_dataset["owner_org"] => 123 }
  end

  let(:themes_cache) do
    { legacy_dataset["theme-primary"] => 345, legacy_dataset["theme-secondary"] => 678}
  end

  describe "#run" do
    it "builds a dataset from a legacy dataset" do

      described_class.new(legacy_dataset, orgs_cache, themes_cache).run

      imported_dataset = Dataset.find_by(uuid: legacy_dataset["id"])

      expect(imported_dataset.uuid).to eql(legacy_dataset["id"])
      expect(imported_dataset.legacy_name).to eql(legacy_dataset["name"])
      expect(imported_dataset.legacy_metadata).to eql("")
      expect(imported_dataset.title).to eql(legacy_dataset["title"])
      expect(imported_dataset.summary).to eql(legacy_dataset["notes"])
      expect(imported_dataset.description).to eql(legacy_dataset["notes"])
      expect(imported_dataset.organisation_id).to eql(123)
      expect(imported_dataset.status).to eql("published")
      expect(imported_dataset.published_date.to_i).to eql(DateTime.parse(legacy_dataset["metadata_created"]).to_i)
      expect(imported_dataset.created_at.to_i).to eql(DateTime.parse(legacy_dataset["metadata_created"]).to_i)
      expect(imported_dataset.last_updated_at.to_i).to eql(DateTime.parse(legacy_dataset["metadata_modified"]).to_i)
      expect(imported_dataset.contact_name).to eql(legacy_dataset["contact-name"])
      expect(imported_dataset.contact_email).to eql(legacy_dataset["contact-email"])
      expect(imported_dataset.contact_phone).to eql(legacy_dataset["contact-phone"])
      expect(imported_dataset.foi_name).to eql(legacy_dataset["foi-name"])
      expect(imported_dataset.foi_email).to eql(legacy_dataset["foi-email"])
      expect(imported_dataset.foi_phone).to eql(legacy_dataset["foi-phone"])
      expect(imported_dataset.foi_web).to eql(legacy_dataset["foi-web"])
      expect(imported_dataset.theme_id).to eql(345)
      expect(imported_dataset.secondary_theme_id).to eql(678)
    end
  end

  describe "#build_frequency" do
    it "returns 'never' if frequency has no value" do
      legacy_dataset["update_frequency"] = nil
      frequency = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_frequency

      expect(frequency).to eql ("never")
    end

    it "returns 'never' if frequency has an unknown value" do
      legacy_dataset["update_frequency"] = "bi-foobarly"
      frequency = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_frequency

      expect(frequency).to eql ("never")
    end

    it "returns 'annually' if legacy frequency is 'annual'" do
      legacy_dataset["update_frequency"] = "annual"
      frequency = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_frequency

      expect(frequency).to eql ("annually")
    end

    it "returns 'monthly' if legacy frequency is 'monthly'" do
      legacy_dataset["update_frequency"] = "monthly"
      frequency = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_frequency

      expect(frequency).to eql ("monthly")
    end

    it "returns 'quarterly' if legacy frequency is 'quarterly'" do
      legacy_dataset["update_frequency"] = "quarterly"
      frequency = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_frequency

      expect(frequency).to eql("quarterly")
    end

    # DEPRECATED: This logic is incorrect and has been corrected. Part of the reason why time series datasets were not displaying properly

    # it "returns 'never' if any datafile has no date" do
    #   legacy_dataset["resources"] = [
    #     {
    #       "description": "Datafile 1",
    #       "format": "CSV",
    #       "date": ""
    #     }
    #   ]
    #
    #   frequency = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_frequency
    #
    #   expect(frequency).to eql('never')
    # end
  end

  describe "#build_location" do
    it "titleizes and joins location(s)" do
      location = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_location
      expect(location).to eql('Scotland, Wales')
    end
  end

  describe "#build_type" do
    it "returns 'inspire' if dataset has UKLP in extras" do
      type = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_type
      expect(type).to eql("inspire")
    end
  end

  describe "#build_licence" do
    it "returns 'no-license' if licence has no value specified" do
    end
  end

  describe "#build_licence_other" do
    it "returns 'no-license' if licence has no value specified" do
    end
  end

  # it "determines if harvested" do
  # harvested: harvested?(legacy_dataset),
  # end

  describe "#add_inspire_metadata" do
    it "creates an Inspire dataset for the imported dataset" do
    end
  end
end
