require 'rails_helper'

describe Legacy::DatasetImportService do
  let(:orgs_cache) do
    {legacy_dataset["owner_org"] => 123}
  end

  let(:themes_cache) do
    { legacy_dataset["theme-primary"] => 345, legacy_dataset["theme-secondary"] => 678}
  end

  describe "legacy timeseries datasets" do
    let(:legacy_dataset) do
      file_path = Rails.root.join('spec', 'fixtures', 'timeseries_dataset.json')
      legacy_land_registry_dataset = File.read(file_path)
      JSON.parse(legacy_land_registry_dataset).with_indifferent_access
    end

    it "imports" do
      Legacy::DatasetImportService.new(legacy_dataset, orgs_cache, themes_cache).run
      expect(Dataset.last.frequency).to eq('monthly')
      expect(Dataset.last.links.count).to eq(3)
      expect(Dataset.last.docs.count).to eq(1)
    end
  end

  describe "legacy non timeseries dataset" do
    let(:legacy_dataset) do
      file_path = Rails.root.join('spec', 'fixtures', 'non_timeseries_dataset.json')
      legacy_land_registry_dataset = File.read(file_path)
      JSON.parse(legacy_land_registry_dataset).with_indifferent_access
    end

    it "imports" do
      Legacy::DatasetImportService.new(legacy_dataset, orgs_cache, themes_cache).run
      expect(Dataset.last.frequency).to eq('never')
      expect(Dataset.last.docs.count).to eq(4)
    end
  end
end

