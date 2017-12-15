require "rails_helper"

describe 'datafiles' do
  set_up_models

  before(:each) do
    user
    sign_in_user
    build_datasets

    click_link 'Manage datasets'
    click_dataset(published_dataset)
  end

  it "should be able to add a new file" do
    link = published_dataset.links.first

    click_change(:datalinks)
    expect(page).to have_content(link.name)

    click_link 'Add another link'
    fill_in 'link[url]', with: 'http://google.com'
    fill_in 'link[name]', with: 'my other test file'
    click_button 'Save and continue'
    expect(page).to have_content('my other test file')
  end

  it "should be able to edit an existing file" do
    link = published_dataset.links.first

    click_change(:datalinks)
    expect(page).to have_content(link.name)

    click_link 'Edit'
    fill_in 'link[name]', with: 'my published test file extreme edition'

    click_button 'Save and continue'
    expect(page).to have_content('my published test file extreme edition')
  end

  it "should be able to remove a file" do
    link = published_dataset.links.first

    click_change(:datalinks)
    expect(page).to have_content(link.name)

    click_link 'Delete'
    expect(page).to have_content "Are you sure you want to delete ‘#{link.name}’?"

    click_link 'Yes, delete this link'
    expect(page).to have_content "Your link ‘#{link.name}’ has been deleted"
    expect(last_updated_dataset.links).to be_empty
  end

  it "should be able to add a new doc" do
    doc = published_dataset.docs.first

    click_change(:documentation)
    expect(page).to have_content(doc.name)

    click_link 'Add another link'
    fill_in 'doc[url]', with: 'http://google.com/doc'
    fill_in 'doc[name]', with: 'my other test doc'
    click_button 'Save and continue'
    expect(page).to have_content('my other test doc')
  end

  it "should be able to edit an existing doc" do
    doc = published_dataset.docs.first

    click_change(:documentation)
    expect(page).to have_content(doc.name)

    click_link 'Edit'
    fill_in 'doc[name]', with: 'my published test doc extreme edition'
    click_button 'Save and continue'
    expect(page).to have_content('my published test doc extreme edition')
  end

  it "should be able to remove a doc" do
    doc = published_dataset.docs.first

    click_change(:documentation)
    expect(page).to have_content(doc.name)

    click_link 'Delete'
    expect(page).to have_content "Are you sure you want to delete ‘#{doc.name}’?"

    click_link 'Yes, delete this link'
    expect(page).to have_content "Your link ‘#{doc.name}’ has been deleted"
    expect(last_updated_dataset.docs).to be_empty
  end
end
