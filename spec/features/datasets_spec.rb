require "rails_helper"

describe "creating and editing datasets" do
  # let! used here to force it to eager evaluate before each test
  let! (:org)  { Organisation.create!(name: "land-registry", title: "Land Registry") }
  let! (:user) do
    @user = User.create!(email: "test@localhost",
                 name: "Test User",
                 primary_organisation: org,
                 password: "password",
                 password_confirmation: "password")
  end

  before(:each) do
    visit "/"
    click_link "Sign in"
    fill_in("user_email", with: "test@localhost")
    fill_in("Password", with: "password")
    click_button "Sign in"
  end

  describe "creating datasets" do
    it "should be able to navigate to new dataset form" do
      expect(page).to have_current_path("/tasks")
      click_link "Manage datasets"
      click_link "Create a dataset"
      expect(page).to have_current_path("/datasets/new")
      expect(page).to have_content("Create a dataset")
    end

    it "should be able to start a new draft dataset" do
      visit "/datasets/new"
      fill_in "dataset[title]", with: "my test dataset"
      fill_in "dataset[summary]", with: "my test dataset summary"
      fill_in "dataset[description]", with: "my test dataset description"
      click_button "Save and continue"

      expect(Dataset.where(title: "my test dataset").length).to eq(1)
      expect(Dataset.find_by(title: "my test dataset").creator_id).to eq(@user.id)
    end

    it "should be able to go through the entire dataset creation flow" do
      visit "/datasets/new"

      # PAGE 1: New
      fill_in "dataset[title]", with: "my test dataset"
      fill_in "dataset[summary]", with: "my test dataset summary"
      fill_in "dataset[description]", with: "my test dataset description"
      click_button "Save and continue"

      expect(Dataset.where(title: "my test dataset").length).to eq(1)

      # PAGE 2: Licence
      choose option: "uk-ogl"
      click_button "Save and continue"

      expect(Dataset.last.licence).to eq("uk-ogl")

      # Page 3: Location
      fill_in "dataset[location1]", with: "Aviation House"
      fill_in "dataset[location2]", with: "London"
      fill_in "dataset[location3]", with: "England"
      click_button "Save and continue"

      expect(Dataset.last.location1).to eq("Aviation House")
      expect(Dataset.last.location2).to eq("London")
      expect(Dataset.last.location3).to eq("England")

      # Page 4: Frequency
      choose option: "never"
      click_button "Save and continue"

      expect(Dataset.last.frequency).to eq("never")

      # Page 5: Add Datafile
      fill_in 'datafile[url]', with: 'https://localhost'
      fill_in 'datafile[name]', with: 'my test datafile'
      click_button "Save and continue"

      expect(Dataset.last.datafiles.length).to eq(1)
      expect(Dataset.last.datafiles.last.url).to eq('https://localhost')
      expect(Dataset.last.datafiles.last.name).to eq('my test datafile')

      # Page 6: Add Documents
      fill_in 'datafile[url]', with: 'https://localhost/doc'
      fill_in 'datafile[name]', with: 'my test doc'
      click_button "Save and continue"

      expect(Dataset.last.datafiles.length).to eq(2)
      expect(Dataset.last.datafiles.last.url).to eq('https://localhost/doc')
      expect(Dataset.last.datafiles.last.name).to eq('my test doc')

      # Page 7: Publish Page
      expect(Dataset.last.published).to be(false)
      expect(page).to have_content(Dataset.last.status)
      expect(page).to have_content(Dataset.last.organisation.title)
      expect(page).to have_content(Dataset.last.title)
      expect(page).to have_content(Dataset.last.summary)
      expect(page).to have_content(Dataset.last.description)
      expect(page).to have_content("Open Government Licence")
      expect(page).to have_content(Dataset.last.location1)
      expect(page).to have_content("One-off")
      expect(page).to have_content(Dataset.last.datafiles.first.name)
      expect(page).to have_content(Dataset.last.datafiles.last.name)

      click_button "Publish"

      expect(Dataset.last.published).to be(true)
    end

    describe "should not be able to start a new draft with invalid inputs" do
      before(:each) do
        visit "/datasets/new"
      end

      it "missing title" do
        fill_in "dataset[summary]", with: "my test dataset summary"
        click_button "Save and continue"
        expect(page).to have_content("There was a problem")
        expect(page).to have_content("Title can't be blank")
        expect(Dataset.where(title: "my test dataset").length).to eq(0)
      end

      it "missing summary" do
        fill_in "dataset[title]", with: "my test dataset"
        click_button "Save and continue"
        expect(page).to have_content("There was a problem")
        expect(page).to have_content("Summary can't be blank")
        expect(Dataset.where(title: "my test dataset").length).to eq(0)
      end

      it "missing both" do
        click_button "Save and continue"
        expect(page).to have_content("There was a problem")
        expect(page).to have_content("Title can't be blank")
        expect(page).to have_content("Summary can't be blank")
        expect(Dataset.where(title: "my test dataset").length).to eq(0)
      end
    end
  end
end
