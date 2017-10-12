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

  it "can ckanify its metadata" do


    d = Dataset.new
    d.title = "This is a dataset"
    d.name = "this-is-a-dataset"
    d.summary = "Summary"
    d.frequency = "annually"
    d.organisation_id = @org.id
    d.licence = "uk-ogl"
    d.save

    ckanified_metadata = {
    :id => "#{d.uuid}",
    :name => "this-is-a-dataset",
    :title =>"This is a dataset",
    :notes => "Summary",
    :description => "Summary",
    :organization => {:name => @org.name},
    :update_frequency => "annual",
    :unpublished => true,
    :metadata_created => d.created_at,
    :metadata_modified => nil,
    :geographic_coverage => [""],
    :license_id => "uk-ogl"
    }

    expect(d.ckanify_metadata).to eq ckanified_metadata
  end

end
