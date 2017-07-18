require "rails_helper"

describe 'editing datasets' do
  set_up

  before(:each) do
    sign_in
  end

  it "should be able to go to datasets's page" do
    click_link 'Manage datasets'
    expect(page).to have_content(unpublished_dataset.title)
    expect(page).to have_content(published_dataset.title)
  end

  context 'editing published datasets from show page' do
    before(:each) do
      click_link 'Manage datasets'
      edit_dataset(:published_dataset)
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

    it "should be able to add a new file" do
      click_change(:datalinks)
      expect(page).to have_content("my published test file")
      click_link 'Add another link'

      fill_in 'datafile[url]', with: 'http://localhost'
      fill_in 'datafile[name]', with: 'my other test file'

      click_button 'Save and continue'

      expect(page).to have_content('my other test file')
    end

    it "should be able to edit an existing file" do
      click_change(:datalinks)
      expect(page).to have_content("my published test file")
      click_link 'Edit'

      fill_in 'datafile[name]', with: 'my published test file extreme edition'

      click_button 'Save and continue'

      expect(page).to have_content('my published test file extreme edition')
    end

    it "should be able to remove a file" do
      click_change(:datalinks)
      expect(page).to have_content("my published test file")
      click_link 'Delete'
      expect(page).to have_content "Are you sure you want to delete ‘my published test file’?"
      click_link 'Yes, delete this link'
      expect(page).to have_content "Your link ‘my published test file’ has been deleted"
      expect(last_updated_dataset.links).to be_empty
    end

    it "should be able to add a new doc" do
      click_change(:documentation)
      expect(page).to have_content("my published test doc")
      click_link 'Add another link'

      fill_in 'datafile[url]', with: 'http://localhost/doc'
      fill_in 'datafile[name]', with: 'my other test doc'

      click_button 'Save and continue'

      expect(page).to have_content('my other test doc')
    end

    it "should be able to edit an existing doc" do
      click_change(:documentation)
      expect(page).to have_content("my published test doc")
      click_link 'Edit'

      fill_in 'datafile[name]', with: 'my published test doc extreme edition'

      click_button 'Save and continue'

      expect(page).to have_content('my published test doc extreme edition')
    end

    it "should be able to remove a doc" do
      click_change(:documentation)
      expect(page).to have_content("my published test doc")
      click_link 'Delete'
      expect(page).to have_content "Are you sure you want to delete ‘my published test doc’?"
      click_link 'Yes, delete this link'
      expect(page).to have_content "Your link ‘my published test doc’ has been deleted"
      expect(last_updated_dataset.docs).to be_empty
    end

    it "should be able to publish a published dataset" do
      expect(page).to have_selector("input[type=submit][value='Publish changes']")
    end

    it "should not be possible to delete a published dataset" do
      expect(page).to_not have_selector(:css, 'a[href="/datasets/test-title-published/confirm_delete"]')
      expect(page).to_not have_content('Delete this dataset')
      visit '/datasets/test-title-published/confirm_delete'
      expect(page).to have_content "Published datasets cannot be deleted"
    end

    it "should be able to publish an complete dataset" do
      visit dataset_url(unpublished_dataset)
      expect(unpublished_dataset.published).to be false
      click_button 'Publish'
      expect(last_updated_dataset.id).to eq(unpublished_dataset.id)
      expect(last_updated_dataset.published).to be true
      expect(page).to have_content("Your dataset has been published")
    end

    it "should not be possible to publish an incomplete dataset" do
      visit dataset_url(unfinished_dataset)
      expect(unfinished_dataset.published).to be false
      click_button 'Publish'
      expect(page).to have_content 'There was a problem'
      expect(page).not_to have_content 'Your dataset has been published'
      expect(current_path).to eq '/datasets/test-title-unfinished/publish'
    end
  end

  context "editing draft datasets from the show page" do
    before(:each) do
      click_link 'Manage datasets'
      edit_dataset(:unpublished_dataset)
    end

    it "is possible to delete a draft dataset" do
      click_link 'Delete this dataset'
      expect(current_path).to eq "/datasets/test-title-unpublished/confirm_delete"
      click_link "Yes, delete this dataset"
      expect(current_path).to eq '/manage'
      expect(page).to have_content "The dataset 'test title unpublished' has been deleted"
      expect(page).to_not have_selector(:css, 'a[href="/datasets/test-title-unpublished/edit"]')
    end
  end
end
