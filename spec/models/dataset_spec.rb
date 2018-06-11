require 'rails_helper'

describe Dataset do
  let!(:org) { @org = Organisation.create!(name: "land-registry", title: "Land Registry") }

  it "requires a title and a summary" do
    dataset = Dataset.new(title: "", summary: "")

    dataset.valid?

    expect(dataset.errors[:title]).to include "Please enter a valid title"
    expect(dataset.errors[:summary]).to include "Please provide a summary"
  end

  it "validates title format" do
    dataset = Dataset.new(title: "[][]")

    dataset.valid?
    expect(dataset.errors[:title]).to include "Please enter a valid title"
  end

  it "generates a unique slug and stores it on the name column" do
    dataset = FactoryGirl.create(:dataset,
                                 title: "My awesome dataset")

    expect(dataset.name).to eq(dataset.title.parameterize)
  end

  it "generates a new slug when the title has changed" do
    dataset = FactoryGirl.create(:dataset,
                                 uuid: 1234,
                                 title: "My awesome dataset")

    dataset.update(title: "My Even Better Dataset")

    expect(dataset.name).to eq("my-even-better-dataset")
  end

  describe "#public_updated_at" do
    it "returns the 'updated_at' timestamp for the most recently updated datafile when the dataset has datafiles" do
      dataset = FactoryGirl.create(:dataset, datafiles: [FactoryGirl.create(:datafile)])
      datafile_updated_at = dataset.datafiles.first.updated_at

      expect(dataset.public_updated_at).to eq(datafile_updated_at)
    end

    it "returns the 'updated_at' timestamp for the dataset when the dataset has no datafiles" do
      dataset = FactoryGirl.create(:dataset)
      expect(dataset.public_updated_at).to eq(dataset.updated_at)
    end
  end

  describe "#released" do
    it "returns true when there is a link" do
      dataset = FactoryGirl.create(:dataset, :with_datafile)
      expect(dataset.released).to be_truthy

      dataset = FactoryGirl.create(:dataset, :with_doc)
      expect(dataset.released).to be_truthy
    end

    it "returns false when there is no link" do
      dataset = FactoryGirl.create(:dataset)
      expect(dataset.released).to be_falsey
    end
  end
end
