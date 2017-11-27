require 'rails_helper'

describe Dataset do
  let! (:org)  { @org = Organisation.create!(name: "land-registry", title: "Land Registry") }

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

    dataset.title = "AB"
    dataset.valid?
    expect(dataset.errors[:title]).to include "Please enter a valid title"
  end

  it "generates a unique slug and stores it on the name column" do
    dataset = FactoryGirl.create(:dataset,
                                 title: "My awesome dataset")

    expect(dataset.name).to eq("#{dataset.title}".parameterize)
  end

  it "generates a new slug when the title has changed" do
    dataset = FactoryGirl.create(:dataset,
                                 uuid: 1234,
                                 title: "My awesome dataset")

    dataset.update(title: "My Even Better Dataset")

    expect(dataset.name).to eq("my-even-better-dataset")
  end

  it "validates more strictly when publishing" do
    dataset = Dataset.new(
      title: "dataset",
      summary: "Summary",
      organisation_id: @org.id,
      status: "published")

    dataset.valid?

    expect(dataset.errors[:licence]).to include("Please select a licence for your dataset")
    expect(dataset.errors[:frequency]).to include("Please indicate how often this dataset is updated")
    expect(dataset.errors[:links]).to include("You must add at least one link")
  end

  it "can pass strict validation when publishing" do
    d = Dataset.new(
      title: "dataset",
      summary: "Summary",
      organisation_id: @org.id,
      frequency: "never",
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
      frequency: "never",
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

  it "sets a published_date and last_published_at timestamps when published" do
    first_publish = Time.now
    allow(Time).to receive(:now).and_return(first_publish)
    dataset = FactoryGirl.create(:dataset, links: [FactoryGirl.create(:link)])
    dataset.save
    dataset.publish!

    expect(dataset.published_date).to eq first_publish

    second_publish = Time.now + 1
    allow(Time).to receive(:now).and_return(second_publish)

    dataset.update(title: 'new-title')
    dataset.publish!

    expect(dataset.published_date).to eq first_publish
    expect(dataset.last_published_at).to eq second_publish
  end

end
