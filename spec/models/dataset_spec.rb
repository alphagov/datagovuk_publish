require 'rails_helper'

describe Dataset do

  let! (:org)  { @org = Organisation.create!(name: "land-registry", title: "Land Registry") }

  it "can create a new dataset" do
    d = Dataset.new
    d.title = "This is a dataset"
    d.summary = "Summary"
    d.frequency = "daily"
    d.organisation_id = @org.id
    expect(d.save).to eq(true)
    expect(d.name).to eq("this-is-a-dataset")
  end

  it "requires a valid title" do
    d = Dataset.new
    d.title = "[][]"
    d.summary = "Summary"
    d.frequency = "daily"
    d.organisation_id = @org.id
    expect(d.save).to eq(false)

    d.title = ""
    expect(d.save).to eq(false)

    d.title = "AB"
    expect(d.save).to eq(false)
  end

  it "generates a unique slug and stores it on the name column" do
    dataset = FactoryGirl.create(:dataset,
                                 uuid: 1234,
                                 title: "My awesome dataset")

    expect(dataset.name).to eq("1234-my-awesome-dataset")
  end

  it "generates a new slug when the title has changed" do
    dataset = FactoryGirl.create(:dataset,
                                 uuid: 1234,
                                 title: "My awesome dataset")

    dataset.update(title: "My Even Better Dataset")

    expect(dataset.name).to eq("1234-my-even-better-dataset")
  end

  it "validates more strictly when publishing" do
    d = Dataset.new(
      title: "dataset",
      summary: "Summary",
      organisation_id: @org.id,
      frequency: "daily",
      status: "published")

    expect(d.save).to eq(false)
  end

  it "can pass strict validation when publishing" do
    d = Dataset.new(
      title: "dataset",
      summary: "Summary",
      organisation_id: @org.id,
      frequency: "daily",
      licence: "uk-ogl")

    d.save

    d.links.create(url: "http://127.0.0.1", name: "Test link")

    expect(d.published!).to eq(true)
  end

  it "is not possible to delete a published dataset" do
    d = Dataset.new(
      title: "dataset",
      summary: "Summary",
      organisation_id: @org.id,
      frequency: "daily",
      licence: "uk-ogl")

    d.save

    d.links.create(url: "http://127.0.0.1", name: "Test link")

    d.published!

    expect{ d.destroy }.to raise_exception 'published datasets cannot be deleted'
    expect(Dataset.count).to eq 1

    d.draft!
    d.destroy

    expect(Dataset.count).to eq 0
  end
end
