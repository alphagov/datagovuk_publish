require 'rails_helper'

describe Legacy::DatasetImportService do
  let(:legacy_dataset) do
    file_path = Rails.root.join('spec', 'fixtures', 'legacy_dataset.json')
    legacy_dataset_json = File.read(file_path)
    JSON.parse(legacy_dataset_json)["result"].with_indifferent_access
  end

  let(:timeseries_legacy_dataset) do
    file_path = Rails.root.join('spec', 'fixtures', 'timeseries_dataset.json')
    legacy_land_registry_dataset = File.read(file_path)
    JSON.parse(legacy_land_registry_dataset).with_indifferent_access
  end

  let(:non_timeseries_legacy_dataset) do
    file_path = Rails.root.join('spec', 'fixtures', 'non_timeseries_dataset.json')
    legacy_land_registry_dataset = File.read(file_path)
    JSON.parse(legacy_land_registry_dataset).with_indifferent_access
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

    it "creates the datafiles for the imported dataset" do
      described_class.new(legacy_dataset, orgs_cache, themes_cache).run
      imported_dataset = Dataset.find_by(uuid: legacy_dataset["id"])
      imported_datafiles = imported_dataset.datafiles
      first_imported_datafile = imported_datafiles.first
      first_resource = legacy_dataset["resources"][0]

      expect(imported_datafiles.count).to eql(2)
      expect(first_imported_datafile.uuid).to eql(first_resource["id"])
      expect(first_imported_datafile.format).to eql(first_resource["format"])
      expect(first_imported_datafile.name).to eql(first_resource["description"])
      expect(first_imported_datafile.created_at).to eql(imported_dataset.created_at)
      expect(first_imported_datafile.updated_at).to eql(imported_dataset.last_updated_at)
      expect(first_imported_datafile.start_date).to eql(Date.parse(first_resource["date"]).beginning_of_month)
      expect(first_imported_datafile.end_date).to eql(Date.parse(first_resource["date"]).end_of_month)
    end

    it "builds a dataset from a non timeseries legacy dataset" do
      Legacy::DatasetImportService.new(non_timeseries_legacy_dataset, orgs_cache, themes_cache).run
      expect(Dataset.last.frequency).to eq('never')
      expect(Dataset.last.docs.count).to eq(1)
    end

    it "builds a dataset from a timeseries legacy dataset" do
      Legacy::DatasetImportService.new(timeseries_legacy_dataset, orgs_cache, themes_cache).run
      expect(Dataset.last.frequency).to eq('monthly')

      expect(Dataset.last.links.count).to eq(1)
      expect(Dataset.last.docs.count).to eq(1)
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
  end

  describe "#build_location" do
    it "titleizes and joins location(s)" do
      location = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_location
      expect(location).to eql('Scotland, Wales')
    end
  end

  describe "#build_type" do
    it "returns 'inspire' if dataset has UKLP in extras" do
      legacy_dataset["extras"] = [{
        "value": "True",
        "key": "UKLP",
      }]

      type = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_type
      expect(type).to eql("inspire")
    end
  end

  describe "#build_licence" do
    it "returns 'no-license' if licence has no value specified" do
      legacy_dataset["license_id"] = ""
      licence = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_licence
      expect(licence).to eql("no-licence")
    end

    it "returns 'other' if the licence is anything other than 'uk-ogl'" do
      legacy_dataset["license_id"] = "foo"
      licence = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_licence
      expect(licence).to eql("other")
    end
  end

  describe "#build_licence_other" do
    it "returns the name of the licence if it is anything other than 'uk-ogl'" do
      legacy_dataset["license_id"] = "foo"
      licence_other = described_class.new(legacy_dataset, orgs_cache, themes_cache).build_licence_other
      expect(licence_other).to eql("foo")
    end
  end

  describe "#harvested?" do
    it "is true if legacy dataset has a harvest_object_id" do
      legacy_dataset["extras"] = [{
        "value": "123",
        "key": "harvest_object_id",
      }]

      harvested = described_class.new(legacy_dataset, orgs_cache, themes_cache).harvested?
      expect(harvested).to be true
    end

    it "is false if the legacy dataset has no harvest extra" do
      harvested = described_class.new(legacy_dataset, orgs_cache, themes_cache).harvested?
      expect(harvested).to be false
    end
  end

  describe "#create_inspire_dataset" do
    it "creates an Inspire dataset for a UKLP imported dataset" do
      legacy_dataset["extras"] = [
      {
        "value": "True",
        "key": "UKLP",
      },
        {
        "value": "bbox east long",
        "key": "bbox-east-long"
      },
        {
        "value": "bbox north lat",
        "key": "bbox-north-lat"
      },
        {
        "value": "bbox south lat",
        "key": "bbox-south-lat"
      },
        {
        "value": "bbox west long",
        "key": "bbox-west-long"
      },
        {
        "value": "coupled resource",
        "key": "coupled-resource"
      },
        {
        "value": "dataset reference date",
        "key": "dataset-reference-date"
      },
        {
        "value": "frequency of update",
        "key": "frequency-of-update"
      },
        {
        "value": "harvest object id",
        "key": "harvest_object_id"
      },
        {
        "value": "harvest source reference",
        "key": "harvest_source_reference"
      },
        {
        "value": "import source",
        "key": "import_source"
      },
        {
        "value": "metadata date",
        "key": "metadata-date"
      },
        {
        "value": "metadata language",
        "key": "metadata-language"
      },
        {
        "value": "provider",
        "key": "provider"
      },
        {
        "value": "resource type",
        "key": "resource-type"
      },
        {
        "value": "responsible party",
        "key": "responsible-party"
      },
        {
        "value": "spatial",
        "key": "spatial"
      },
        {
        "value": "spatial data service type",
        "key": "spatial-data-service-type"
      },
        {
        "value": "spatial reference system",
        "key": "spatial-reference-system"
      },
        {
        "value": "guid",
        "key": "guid"
      }
      ]

      described_class.new(legacy_dataset, orgs_cache, themes_cache).run

      imported_dataset = Dataset.find_by(uuid: legacy_dataset["id"])
      inspire_dataset = InspireDataset.find_by(dataset_id: imported_dataset.id)

      expect(inspire_dataset.bbox_east_long).to eql('bbox east long')
      expect(inspire_dataset.bbox_north_lat).to eql('bbox north lat')
      expect(inspire_dataset.bbox_south_lat).to eql('bbox south lat')
      expect(inspire_dataset.bbox_west_long).to eql('bbox west long')
      expect(inspire_dataset.coupled_resource).to eql('coupled resource')
      expect(inspire_dataset.dataset_reference_date).to eql('dataset reference date')
      expect(inspire_dataset.frequency_of_update).to eql('frequency of update')
      expect(inspire_dataset.harvest_object_id).to eql('harvest object id')
      expect(inspire_dataset.harvest_source_reference).to eql('harvest source reference')
      expect(inspire_dataset.import_source).to eql('import source')
      expect(inspire_dataset.metadata_date).to eql('metadata date')
      expect(inspire_dataset.metadata_language).to eql('metadata language')
      expect(inspire_dataset.provider).to eql('provider')
      expect(inspire_dataset.resource_type).to eql('resource type')
      expect(inspire_dataset.responsible_party).to eql('responsible party')
      expect(inspire_dataset.spatial).to eql('spatial')
      expect(inspire_dataset.spatial_data_service_type).to eql('spatial data service type')
      expect(inspire_dataset.spatial_reference_system).to eql('spatial reference system')
      expect(inspire_dataset.guid).to eql('guid')
    end
  end
end
