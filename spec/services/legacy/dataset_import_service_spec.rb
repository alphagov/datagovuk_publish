require 'rails_helper'

describe Legacy::DatasetImportService do
  let(:legacy_dataset) { create_dataset_from('legacy_dataset.json') }
  let(:legacy_dataset_without_licence) { create_dataset_from('legacy_dataset_no_licence.json') }
  let(:timeseries_legacy_dataset) { create_dataset_from('timeseries_dataset.json') }
  let(:daily_timeseries_legacy_dataset_with_invalid_date) { create_dataset_from('daily_timeseries_dataset_with_invalid_date.json') }
  let(:monthly_timeseries_legacy_dataset_with_invalid_date) { create_dataset_from('monthly_timeseries_dataset_with_invalid_date.json') }
  let(:non_timeseries_legacy_dataset) { create_dataset_from('non_timeseries_dataset.json') }

  let(:orgs_cache) { { legacy_dataset["owner_org"] => 123 } }
  let(:topics_cache) { { 'business-and-economy' => 1 } }

  describe "#run" do
    it "builds a dataset from a legacy dataset" do
      Legacy::DatasetImportService.new(legacy_dataset, orgs_cache, topics_cache).run

      imported_dataset = Dataset.find_by(uuid: legacy_dataset["id"])
      most_recent_datafile = legacy_dataset["resources"].last
      parsed_datafile_created_date = Time.zone.parse(most_recent_datafile["created"]).utc

      expect(imported_dataset.uuid).to eql(legacy_dataset["id"])
      expect(imported_dataset.legacy_name).to eql(legacy_dataset["name"])
      expect(imported_dataset.title).to eql(legacy_dataset["title"])
      expect(imported_dataset.summary).to eql(legacy_dataset["notes"])
      expect(imported_dataset.description).to eql(legacy_dataset["notes"])
      expect(imported_dataset.organisation_id).to eql(123)
      expect(imported_dataset.status).to eql("published")
      expect(imported_dataset.licence_code).to eql("uk-ogl")
      expect(imported_dataset.licence_title).to eql("Open Government Licence")
      expect(imported_dataset.licence_url).to eql("http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/")
      expect(imported_dataset.licence_custom).to eql("Custom licence")
      expect(imported_dataset.published_date).to eq(Time.zone.parse(legacy_dataset["metadata_created"]))
      expect(imported_dataset.created_at).to eq(Time.zone.parse(legacy_dataset["metadata_created"]))
      expect(imported_dataset.last_updated_at).to eq(Time.zone.parse(legacy_dataset["metadata_modified"]))
      expect(imported_dataset.contact_name).to eql(legacy_dataset["contact-name"])
      expect(imported_dataset.contact_email).to eql(legacy_dataset["contact-email"])
      expect(imported_dataset.contact_phone).to eql(legacy_dataset["contact-phone"])
      expect(imported_dataset.foi_name).to eql(legacy_dataset["foi-name"])
      expect(imported_dataset.foi_email).to eql(legacy_dataset["foi-email"])
      expect(imported_dataset.foi_phone).to eql(legacy_dataset["foi-phone"])
      expect(imported_dataset.foi_web).to eql(legacy_dataset["foi-web"])
      expect(imported_dataset.topic_id).to eql(1)
      expect(imported_dataset.datafile_last_updated_at).to eql(parsed_datafile_created_date)
    end

    it "sets datafile_last_updated_at so the most recent datafile's last_modified_at when present" do
      legacy_dataset["resources"].first["last_modified_at"] = "2017-12-14T09:35:25.928982"
      Legacy::DatasetImportService.new(legacy_dataset, orgs_cache, topics_cache).run

      imported_dataset = Dataset.find_by(uuid: legacy_dataset["id"])
      parsed_last_modified_date = Time.zone.parse("2017-12-14T09:35:25.928982").utc
      expect(imported_dataset.datafile_last_updated_at).to eql(parsed_last_modified_date)
    end

    it "correctly sets licence fields where no licence" do
      Legacy::DatasetImportService.new(legacy_dataset_without_licence, orgs_cache, topics_cache).run

      imported_dataset = Dataset.find_by(uuid: legacy_dataset_without_licence["id"])

      expect(imported_dataset.licence_code).to be_nil
      expect(imported_dataset.licence_title).to be_nil
      expect(imported_dataset.licence_url).to be_nil
      expect(imported_dataset.licence_custom).to eql("")
    end

    it "creates the datafiles for the imported dataset" do
      first_resource = legacy_dataset["resources"][0]
      first_resource["last_modified_at"] = "2017-12-14T09:35:25.928982"

      Legacy::DatasetImportService.new(legacy_dataset, orgs_cache, topics_cache).run
      imported_dataset = Dataset.find_by(uuid: legacy_dataset["id"])
      imported_datafiles = imported_dataset.links
      first_imported_datafile = imported_datafiles.first

      expect(imported_datafiles.count).to eql(3)
      expect(first_imported_datafile.uuid).to eql(first_resource["id"])
      expect(first_imported_datafile.format).to eql(first_resource["format"])
      expect(first_imported_datafile.name).to eql(first_resource["description"])
      expect(first_imported_datafile.created_at).to eql(Time.parse(first_resource["created"]))
      expect(first_imported_datafile.updated_at).to eql(Time.parse(first_resource["last_modified_at"]))
      expect(first_imported_datafile.end_date).to eql(Date.parse(first_resource["date"]).end_of_month)
    end

    it "sets datafile created_at date to resource created date, if present" do
      legacy_dataset['resources'].first['created'] = nil
      dataset_with_resource_without_created_date = legacy_dataset
      Legacy::DatasetImportService.new(dataset_with_resource_without_created_date, orgs_cache, topics_cache).run
      imported_dataset = Dataset.find_by(uuid: legacy_dataset["id"])
      imported_datafiles = imported_dataset.links
      first_imported_datafile = imported_datafiles.first

      expect(first_imported_datafile.created_at).to eql(imported_dataset.created_at)
    end

    it "builds a dataset from a non timeseries legacy dataset" do
      Legacy::DatasetImportService.new(non_timeseries_legacy_dataset, orgs_cache, topics_cache).run
      expect(Dataset.last.frequency).to eq('never')
      expect(Dataset.last.docs.count).to eq(1)
    end

    it "builds a dataset from a timeseries legacy dataset" do
      Legacy::DatasetImportService.new(timeseries_legacy_dataset, orgs_cache, topics_cache).run

      expect(Dataset.last.frequency).to eq('monthly')
      expect(Dataset.last.datafiles.count).to eq(1)
      expect(Dataset.last.docs.count).to eq(1)
    end
  end

  describe "Invalid dates" do
    it "builds a dataset from a daily timeseries legacy dataset with an invalid date" do
      Legacy::DatasetImportService.new(daily_timeseries_legacy_dataset_with_invalid_date, orgs_cache, topics_cache).run

      expect(Dataset.last.datafiles.count).to eq(1)
    end

    it "builds a dataset from a monthly timeseries legacy dataset with an invalid date" do
      Legacy::DatasetImportService.new(monthly_timeseries_legacy_dataset_with_invalid_date, orgs_cache, topics_cache).run

      expect(Dataset.last.links.count).to eq(1)
    end
  end

  describe "#build_frequency" do
    it "returns 'never' if frequency has no value" do
      legacy_dataset["update_frequency"] = nil
      frequency = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_frequency

      expect(frequency).to eql "never"
    end

    it "returns 'never' if frequency has an unknown value" do
      legacy_dataset["update_frequency"] = "bi-foobarly"
      frequency = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_frequency

      expect(frequency).to eql "never"
    end

    it "returns 'annually' if legacy frequency is 'annual'" do
      legacy_dataset["update_frequency"] = "annual"
      frequency = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_frequency

      expect(frequency).to eql "annually"
    end

    it "returns 'monthly' if legacy frequency is 'monthly'" do
      legacy_dataset["update_frequency"] = "monthly"
      frequency = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_frequency

      expect(frequency).to eql "monthly"
    end

    it "returns 'quarterly' if legacy frequency is 'quarterly'" do
      legacy_dataset["update_frequency"] = "quarterly"
      frequency = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_frequency

      expect(frequency).to eql("quarterly")
    end
  end

  describe "#build_location" do
    it "titleizes and joins location(s)" do
      location = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_location
      expect(location).to eql('Scotland, Wales')
    end
  end

  describe "#build_type" do
    it "returns 'inspire' if dataset has UKLP in extras" do
      legacy_dataset["extras"] = [{
                                    "value": "True",
                                    "key": "UKLP",
                                  }]

      type = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_type
      expect(type).to eql("inspire")
    end
  end

  describe "#build_topic_id" do
    it "returns the correct topic_id if license has a valid topic" do
      legacy_dataset["theme-primary"] = "Business & Economy"
      topic_id = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_topic_id

      expect(topic_id).to eql(1)
    end

    it "returns nil if the licence has a missing topic" do
      legacy_dataset["theme-primary"] = ""
      topic_id = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_topic_id

      expect(topic_id).to eql(nil)
    end

    it "returns nil if the licence has an invalid topic" do
      legacy_dataset["theme-primary"] = "Some invalid topic"
      topic_id = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_topic_id

      expect(topic_id).to eql(nil)
    end
  end

  describe "#build_licence" do
    it "returns 'no-license' if licence has no value specified" do
      legacy_dataset["license_id"] = ""
      licence = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_licence
      expect(licence).to eql("no-licence")
    end

    it "returns 'other' if the licence is anything other than 'uk-ogl'" do
      legacy_dataset["license_id"] = "foo"
      licence = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_licence
      expect(licence).to eql("other")
    end
  end

  describe "#build_licence_other" do
    it "returns the name of the licence if it is anything other than 'uk-ogl'" do
      legacy_dataset["license_id"] = "foo"
      licence_other = described_class.new(legacy_dataset, orgs_cache, topics_cache).build_licence_other
      expect(licence_other).to eql("foo")
    end
  end

  describe "#harvested?" do
    it "is true if legacy dataset has a harvest_object_id" do
      legacy_dataset["extras"] = [{
                                    "value": "123",
                                    "key": "harvest_object_id",
                                  }]

      harvested = described_class.new(legacy_dataset, orgs_cache, topics_cache).harvested?
      expect(harvested).to be true
    end

    it "is false if the legacy dataset has no harvest extra" do
      harvested = described_class.new(legacy_dataset, orgs_cache, topics_cache).harvested?
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

      described_class.new(legacy_dataset, orgs_cache, topics_cache).run

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

  def create_dataset_from(json)
    file_path = Rails.root.join('spec', 'fixtures', json)
    legacy_land_registry_dataset = File.read(file_path)
    JSON.parse(legacy_land_registry_dataset).with_indifferent_access
  end
end
