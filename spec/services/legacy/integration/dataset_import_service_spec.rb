require 'rails_helper'

describe Legacy::DatasetImportService do
  let(:legacy_dataset) do
    file_path = Rails.root.join('spec', 'fixtures', 'land_registry_dataset.json')
    legacy_land_registry_dataset = File.read(file_path)
    JSON.parse(legacy_land_registry_dataset).with_indifferent_access
  end

  let(:orgs_cache) do
    {legacy_dataset["owner_org"] => 123}
  end

  let(:themes_cache) do
    { legacy_dataset["theme-primary"] => 345, legacy_dataset["theme-secondary"] => 678}
  end

  describe "#run" do
    it "builds a dataset from a legacy dataset" do
      Legacy::DatasetImportService.new(legacy_dataset, orgs_cache, themes_cache).run
      expect(Dataset.last.frequency).to eq('monthly')
      expect(Dataset.last.docs.count).to eq(2)
      expect(Dataset.last.links.count).to eq(2)


      binding.pry
    end
  end
end
