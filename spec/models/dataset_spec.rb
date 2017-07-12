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

  it "can generate unique slugs" do
    d1 = Dataset.new
    d1.title = "dataset"
    d1.summary = "Summary"
    d1.organisation_id = @org.id
    d1.frequency = "daily"
    expect(d1.save).to eq(true)

    d2 = Dataset.new
    d2.title = "dataset"
    d2.summary = "Summary"
    d2.organisation_id = @org.id
    d2.frequency = "daily"
    expect(d2.save).to eq(true)

    expect(d2.name).to eq("dataset-2")
  end

  it "validates more strictly when publishing" do
    d = Dataset.new
    d.title = "dataset"
    d.summary = "Summary"
    d.organisation_id = @org.id
    d.frequency = "daily"
    d.published = true
    expect(d.save).to eq(false)
  end

  it "can pass strict validation when publishing" do
    d = Dataset.new
    d.title = "dataset"
    d.summary = "Summary"
    d.organisation_id = @org.id
    d.frequency = "daily"
    d.save()

    Datafile.create(url: "http://127.0.0.1", name: "Test link", dataset: d)

    d.licence = "uk-ogl"
    d.published = true

    expect(d.save).to eq(true)
  end

  it "is not possible to delete a published dataset" do
    d = Dataset.new
    d.title = "dataset"
    d.summary = "Summary"
    d.organisation_id = @org.id
    d.frequency = "daily"
    d.licence = "uk-ogl"
    d.save()

    Datafile.create(url: "http://127.0.0.1", name: "Test link", dataset: d)

    d.published = true

    expect{d.destroy}.to raise_exception 'published datasets cannot be deleted'
    expect(Dataset.count).to eq 1

    d.published = false
    d.destroy

    expect(Dataset.count).to eq 0
  end
end
