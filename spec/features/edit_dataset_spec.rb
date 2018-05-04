require "rails_helper"

describe 'editing datasets' do
  let(:land) { FactoryGirl.create(:organisation) }
  let!(:user) { FactoryGirl.create(:user, primary_organisation: land) }
  let!(:topic) { FactoryGirl.create(:topic) }

  let!(:published_dataset) do
    FactoryGirl.create(:dataset,
                       organisation: land,
                       status: "published",
                       datafiles: [FactoryGirl.create(:datafile)],
                       docs: [FactoryGirl.create(:doc)],
                       creator: user,
                       owner: user,
                       topic: topic)
  end

  let!(:unpublished_dataset) do
    FactoryGirl.create(:dataset,
                       organisation: land,
                       status: "draft",
                       creator: user,
                       owner: user)
  end

  before(:each) do
    sign_in_as(user)
  end

  it "should be able to go to datasets's page" do
    click_link 'Manage datasets'
    expect(page).to have_content(unpublished_dataset.title)
    expect(page).to have_content(published_dataset.title)
  end

  context 'editing published datasets from show page' do
    before(:each) do
      click_link 'Manage datasets'
      click_dataset(published_dataset)
    end

    it "should be able to update title" do
      click_change(:title)
      fill_in 'dataset[title]', with: 'a new title'
      click_button 'Save and continue'

      expect(page).to have_content('a new title')
      expect(last_updated_dataset.title).to eq('a new title')
    end

    it "should be able to update summary" do
      click_change(:summary)
      fill_in 'dataset[summary]', with: 'a new summary'
      click_button 'Save and continue'

      expect(page).to have_content('a new summary')
      expect(last_updated_dataset.summary).to eq('a new summary')
    end

    it "should be able to update additional info" do
      click_change(:additional_info)
      fill_in 'dataset[description]', with: 'a new description'
      click_button 'Save and continue'

      expect(page).to have_content('a new description')
      expect(last_updated_dataset.description).to eq('a new description')
    end

    it "should be able to update topic" do
      topic = FactoryGirl.create(:topic, title: 'Environment', name: 'environment')
      click_change(:topic)
      choose option: topic.id
      click_button 'Save and continue'

      expect(page).to have_content('Environment')
      expect(last_updated_dataset.topic.title).to eq('Environment')
    end

    it "should be able to update licence" do
      click_change(:licence)
      choose(option: 'other')
      fill_in 'dataset[licence_other]', with: 'MIT'
      click_button 'Save and continue'

      expect(page).to have_content('MIT')
      expect(last_updated_dataset.licence).to eq('other')
      expect(last_updated_dataset.licence_other).to eq('MIT')
    end

    it "should be able to update location" do
      click_change(:location)
      fill_in 'dataset[location1]', with: 'there'
      click_button 'Save and continue'

      expect(page).to have_content('there')
      expect(last_updated_dataset.location1).to eq('there')
    end

    it "should be able to update frequency" do
      click_change(:frequency)
      choose option: 'daily'
      click_button 'Save and continue'

      expect(page).to have_content('Daily')
      expect(last_updated_dataset.frequency).to eq('daily')
    end

    it "should be able to publish a published dataset" do
      visit dataset_url(published_dataset.uuid, published_dataset.name)
      expect(page).to have_selector("input[type=submit][value='Publish changes']")
    end

    it "should not be possible to delete a published dataset" do
      visit dataset_url(published_dataset.uuid, published_dataset.name)
      expect(page).to_not have_selector(:css, 'a[href="/datasets/test-title-published/confirm_delete"]')
      expect(page).to_not have_content('Delete this dataset')

      visit confirm_delete_dataset_path(published_dataset.uuid, published_dataset.name)
      expect(page).to have_content "Published datasets cannot be deleted"
    end

    it "should be able to publish a complete dataset" do
      visit dataset_url(unpublished_dataset.uuid, unpublished_dataset.name)
      expect(unpublished_dataset).not_to be_published

      click_button 'Publish'
      expect(last_updated_dataset.id).to eq(unpublished_dataset.id)
      expect(last_updated_dataset).to be_published
      expect(page).to have_content("Your dataset has been published")
    end

    it "can publish an incomplete dataset" do
      unfinished_dataset = FactoryGirl.create(:dataset,
                                               creator: user,
                                               owner: user)

      visit dataset_url(unfinished_dataset.uuid, unfinished_dataset.name)
      expect(unfinished_dataset).not_to be_published

      click_button 'Publish'
      expect(page).to have_content 'Your dataset has been published'
    end
  end

  context "editing draft datasets from the show page" do
    it "is possible to delete a draft dataset" do
      visit dataset_url(unpublished_dataset.uuid, unpublished_dataset.name)
      click_link 'Delete this dataset'
      expect(current_path).to eq confirm_delete_dataset_path(unpublished_dataset.uuid, unpublished_dataset.name)
      click_link "Yes, delete this dataset"
      expect(current_path).to eq '/manage'
      expect(page).to have_content "The dataset '#{unpublished_dataset.title}' has been deleted"
      expect(page).to_not have_selector(:css, 'a[href="/datasets/test-title-unpublished/edit"]')
    end
  end
end
