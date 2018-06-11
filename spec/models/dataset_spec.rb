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
end
