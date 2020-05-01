require "rails_helper"

describe "editing datasets" do
  let(:land) { create(:organisation) }
  let!(:user) { create(:user, primary_organisation: land) }

  let!(:dataset) do
    create(:dataset, :with_datafile, :with_doc, organisation: land,
                                                creator: user)
  end

  before(:each) do
    sign_in_as(user)
    click_link "Manage datasets"
    click_dataset(dataset)
  end

  it "should be able to update title" do
    click_change(:title)
    fill_in "dataset[title]", with: "a new title"
    click_button "Save and continue"

    expect(page).to have_content("a new title")
    expect(last_updated_dataset.title).to eq("a new title")
  end

  it "should be able to update summary" do
    click_change(:summary)
    fill_in "dataset[summary]", with: "a new summary"
    click_button "Save and continue"

    expect(page).to have_content("a new summary")
    expect(last_updated_dataset.summary).to eq("a new summary")
  end

  it "should be able to update additional info" do
    click_change(:additional_info)
    fill_in "dataset[description]", with: "a new description"
    click_button "Save and continue"

    expect(page).to have_content("a new description")
    expect(last_updated_dataset.description).to eq("a new description")
  end

  it "should be able to update topic" do
    topic = create(:topic, title: "Environment", name: "environment")
    click_change(:topic)
    choose option: topic.id
    click_button "Save and continue"

    expect(page).to have_content("Environment")
    expect(last_updated_dataset.topic.title).to eq("Environment")
  end

  it "should be able to update licence" do
    click_change(:licence_code)
    choose(option: "cc-by")
    click_button "Save and continue"

    expect(page).to have_content("Creative Commons Attribution")
    expect(last_updated_dataset.licence_code).to eq("cc-by")
  end

  it "should be able to update location" do
    click_change(:location)
    fill_in "dataset[location1]", with: "there"
    click_button "Save and continue"

    expect(page).to have_content("there")
    expect(last_updated_dataset.location1).to eq("there")
  end

  it "should be able to update frequency" do
    click_change(:frequency)
    choose option: "daily"
    click_button "Save and continue"

    expect(page).to have_content("Daily")
    expect(last_updated_dataset.frequency).to eq("daily")
  end

  it "should be able to add a new file" do
    datafile = dataset.datafiles.first

    click_change(:datalinks)
    expect(page).to have_content(datafile.name)

    click_link "Add a link"
    fill_in "datafile[url]", with: "http://google.com"
    fill_in "datafile[name]", with: "my other test file"
    click_button "Save and continue"
    expect(page).to have_content("my other test file")
  end

  it "should be able to edit an existing file" do
    datafile = dataset.datafiles.first

    click_change(:datalinks)
    expect(page).to have_content(datafile.name)

    click_link "Edit"
    fill_in "datafile[name]", with: "my published test file extreme edition"

    click_button "Save and continue"
    expect(page).to have_content("my published test file extreme edition")
  end

  it "should be able to remove a file" do
    datafile = dataset.datafiles.first

    click_change(:datalinks)
    expect(page).to have_content(datafile.name)

    click_link "Delete"
    expect(page).to have_content "Are you sure you want to delete ‘#{datafile.name}’?"

    click_link "Yes, delete this link"
    expect(page).to have_content "Your link ‘#{datafile.name}’ has been deleted"
    expect(last_updated_dataset.datafiles).to be_empty
  end

  it "should be able to add a new doc" do
    doc = dataset.docs.first

    click_change(:documentation)
    expect(page).to have_content(doc.name)

    click_link "Add a link"
    fill_in "doc[url]", with: "http://google.com/doc"
    fill_in "doc[name]", with: "my other test doc"
    click_button "Save and continue"
    expect(page).to have_content("my other test doc")
  end

  it "should be able to edit an existing doc" do
    doc = dataset.docs.first

    click_change(:documentation)
    expect(page).to have_content(doc.name)

    click_link "Edit"
    fill_in "doc[name]", with: "my published test doc extreme edition"
    click_button "Save and continue"
    expect(page).to have_content("my published test doc extreme edition")
  end

  it "should be able to remove a doc" do
    doc = dataset.docs.first

    click_change(:documentation)
    expect(page).to have_content(doc.name)

    click_link "Delete"
    expect(page).to have_content "Are you sure you want to delete ‘#{doc.name}’?"

    click_link "Yes, delete this link"
    expect(page).to have_content "Your link ‘#{doc.name}’ has been deleted"
    expect(last_updated_dataset.docs).to be_empty
  end

  it "should be able to delete a dataset" do
    visit dataset_url(dataset.uuid, dataset.name)
    click_link "Delete this dataset"
    expect(current_path).to eq confirm_delete_dataset_path(dataset.uuid, dataset.name)
    click_link "Yes, delete this dataset"
    expect(current_path).to eq "/manage"
    expect(page).to have_content "The dataset '#{dataset.title}' has been deleted"
    expect(page).to_not have_selector(:xpath, "//a[@href='#{dataset_path(dataset.uuid, dataset.name)}']")
  end
end
