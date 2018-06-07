require "rails_helper"

describe 'datafiles' do
  let(:land) { FactoryGirl.create(:organisation) }
  let!(:user) { FactoryGirl.create(:user, primary_organisation: land) }

  let(:published_dataset) do
    FactoryGirl.create(:dataset,
                       organisation: land,
                       status: "published",
                       datafiles: [FactoryGirl.create(:datafile)],
                       docs: [FactoryGirl.create(:doc)],
                       creator: user)
  end

  before(:each) do
    sign_in_as(user)
    visit dataset_path(published_dataset.uuid, published_dataset.name)
  end

  it "should be able to add a new file" do
    datafile = published_dataset.datafiles.first

    click_change(:datalinks)
    expect(page).to have_content(datafile.name)

    click_link 'Add a link'
    fill_in 'datafile[url]', with: 'http://google.com'
    fill_in 'datafile[name]', with: 'my other test file'
    click_button 'Save and continue'
    expect(page).to have_content('my other test file')
  end

  it "should be able to edit an existing file" do
    datafile = published_dataset.datafiles.first

    click_change(:datalinks)
    expect(page).to have_content(datafile.name)

    click_link 'Edit'
    fill_in 'datafile[name]', with: 'my published test file extreme edition'

    click_button 'Save and continue'
    expect(page).to have_content('my published test file extreme edition')
  end

  it "should be able to remove a file" do
    datafile = published_dataset.datafiles.first

    click_change(:datalinks)
    expect(page).to have_content(datafile.name)

    click_link 'Delete'
    expect(page).to have_content "Are you sure you want to delete ‘#{datafile.name}’?"

    click_link 'Yes, delete this link'
    expect(page).to have_content "Your link ‘#{datafile.name}’ has been deleted"
    expect(last_updated_dataset.datafiles).to be_empty
  end

  it "should be able to add a new doc" do
    doc = published_dataset.docs.first

    click_change(:documentation)
    expect(page).to have_content(doc.name)

    click_link 'Add a link'
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
