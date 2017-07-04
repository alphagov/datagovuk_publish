require "rails_helper"

describe "creating and editing datasets" do
  # let! used here to force it to eager evaluate before each test
  let! (:org)  { Organisation.create!(name: "land-registry", title: "Land Registry") }
  let! (:user) do
     User.create!(email: "test@localhost",
                  name: "Test User",
                  primary_organisation: org,
                  password: "password",
                  password_confirmation: "password")
  end
  let! (:unfinished_dataset) do
    Dataset.create!(
      organisation: org,
      title: 'test title unfinished',
      summary: 'test summary',
      creator: user,
      owner: user
    )
  end

  let! (:unpublished_dataset) do
    d = Dataset.create!(
      organisation: org,
      title: 'test title unpublished',
      summary: 'test summary',
      frequency: 'never',
      licence: 'uk-ogl',
      location1: 'somewhere',
      published: false,
      creator: user,
      owner: user
    )

    d.datafiles << Datafile.create!(url: 'http://localhost', name: 'my test file', dataset: d)
    d.datafiles << Datafile.create!(url: 'http://localhost/doc', name: 'my test doc', dataset: d, documentation: true)
    d.save

    d
  end

  let! (:published_dataset) do
    d = Dataset.create!(
      organisation: org,
      title: 'test title published',
      summary: 'test summary',
      frequency: 'never',
      licence: 'uk-ogl',
      location1: 'here',
      published: false,
      creator: user,
      owner: user
    )

    d.datafiles << Datafile.create!(url: 'http://localhost', name: 'my published test file', dataset: d)
    d.datafiles << Datafile.create!(url: 'http://localhost/doc', name: 'my published test doc', dataset: d, documentation: true)
    d.published = true
    d.save

    d
  end


  before(:each) do
    visit "/"
    click_link "Sign in"
    fill_in("user_email", with: "test@localhost")
    fill_in("Password", with: "password")
    click_button "Sign in"
  end

  describe 'unfinished datasets' do
    it 'should be able to show an unfinished dataset' do
      click_link 'Manage datasets'
      expect(page).to have_content(unfinished_dataset.title)
      visit '/datasets/test-title-unfinished'
    end
  end

  describe 'editing datasets' do
    it "should be able to go to datasets's page" do
      click_link 'Manage datasets'
      expect(page).to have_content(unpublished_dataset.title)
      expect(page).to have_content(published_dataset.title)
      first(:link, 'Edit').click
    end

    context 'editing from show page' do
      before(:each) do
        click_link 'Manage datasets'
        first(:link, 'Edit').click
      end

      it "should be able to update title" do
        all(:link, "Change").first.click
        fill_in 'dataset[title]', with: 'a new title'
        click_button 'Save and continue'

        expect(page).to have_content('a new title')
        expect(last_updated_dataset.title).to eq('a new title')
      end

      it "should be able to update summary" do
        all(:link, "Change")[1].click
        fill_in 'dataset[summary]', with: 'a new summary'
        click_button 'Save and continue'

        expect(page).to have_content('a new summary')
        expect(last_updated_dataset.summary).to eq('a new summary')
      end

      it "should be able to update additional info" do
        all(:link, "Change")[2].click
        fill_in 'dataset[description]', with: 'a new description'
        click_button 'Save and continue'

        expect(page).to have_content('a new description')
        expect(last_updated_dataset.description).to eq('a new description')
      end

      it "should be able to update licence" do
        all(:link, "Change")[3].click
        choose(option: 'other')
        fill_in 'dataset[licence_other]', with: 'MIT'
        click_button 'Save and continue'

        expect(page).to have_content('MIT')
        expect(last_updated_dataset.licence).to eq('MIT')
      end

      it "should be able to update location" do
        all(:link, "Change")[4].click
        fill_in 'dataset[location1]', with: 'there'
        click_button 'Save and continue'

        expect(page).to have_content('there')
        expect(last_updated_dataset.location1).to eq('there')
      end

      it "should be able to update frequency" do
        all(:link, "Change")[5].click
        choose option: 'daily'
        click_button 'Save and continue'

        expect(page).to have_content('Daily')
        expect(last_updated_dataset.frequency).to eq('daily')
      end

      it "should be able to add a new file" do
        all(:link, "Change")[6].click
        expect(page).to have_content("my published test file")
        click_link 'Add another link'

        fill_in 'datafile[url]', with: 'http://localhost'
        fill_in 'datafile[name]', with: 'my other test file'

        click_button 'Save and continue'

        expect(page).to have_content('my other test file')
      end

      it "should be able to edit an existing file" do
        all(:link, "Change")[6].click
        expect(page).to have_content("my published test file")
        click_link 'Edit'

        fill_in 'datafile[name]', with: 'my published test file extreme edition'

        click_button 'Save and continue'

        expect(page).to have_content('my published test file extreme edition')
      end

      it "should be able to remove a file" do
        all(:link, "Change")[6].click
        expect(page).to have_content("my published test file")
        click_link 'Delete'
        expect(last_updated_dataset.datafiles.datalinks).to be_empty
      end

      it "should be able to add a new doc" do
        all(:link, "Change")[7].click
        expect(page).to have_content("my published test doc")
        click_link 'Add another link'

        fill_in 'datafile[url]', with: 'http://localhost/doc'
        fill_in 'datafile[name]', with: 'my other test doc'

        click_button 'Save and continue'

        expect(page).to have_content('my other test doc')
      end

      it "should be able to edit an existing doc" do
        all(:link, "Change")[7].click
        expect(page).to have_content("my published test doc")
        click_link 'Edit'

        fill_in 'datafile[name]', with: 'my published test doc extreme edition'

        click_button 'Save and continue'

        expect(page).to have_content('my published test doc extreme edition')
      end

      it "should be able to remove a doc" do
        all(:link, "Change")[7].click
        expect(page).to have_content("my published test doc")
        click_link 'Delete'
        expect(last_updated_dataset.datafiles.documentation).to be_empty

      end

      it "should not be able to publish a published dataset" do
        expect(page).to_not have_selector("input[type=submit][value='Publish']")
      end

      it "should be able to publish an unpublished dataset" do
        visit dataset_url(unpublished_dataset)
        expect(unpublished_dataset.published).to be false
        click_button 'Publish'
        expect(last_updated_dataset.id).to eq(unpublished_dataset.id)
        expect(last_updated_dataset.published).to be true
        expect(page).to have_content("Your dataset has been published")
      end
    end
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
      expect(Dataset.find_by(title: "my test dataset").creator_id).to eq(user.id)
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

      # Files page
      expect(page).to have_content("Links to your data")
      expect(page).to have_content("my test datafile")
      click_link "Save and continue"

      # Page 6: Add Documents
      fill_in 'datafile[url]', with: 'https://localhost/doc'
      fill_in 'datafile[name]', with: 'my test doc'
      click_button "Save and continue"

      expect(Dataset.last.datafiles.length).to eq(2)
      expect(Dataset.last.datafiles.last.url).to eq('https://localhost/doc')
      expect(Dataset.last.datafiles.last.name).to eq('my test doc')

      # Documents page
      expect(page).to have_content("Links to supporting documents")
      expect(page).to have_content("my test doc")
      click_link "Save and continue"

      # Page 9: Publish Page
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

      expect(page).to have_content("Your dataset has been published")
      expect(Dataset.last.published).to be(true)
    end

    describe "should set file dates correctly based on which frequency is set" do
      before(:each) do
        visit "/datasets/new"
        # NEW
        fill_in "dataset[title]", with: "my test dataset"
        fill_in "dataset[summary]", with: "my test dataset summary"
        fill_in "dataset[description]", with: "my test dataset description"
        click_button "Save and continue"
        # LICENCE
        choose option: "uk-ogl"
        click_button "Save and continue"
        # LOCATION
        fill_in "dataset[location1]", with: "Aviation House"
        fill_in "dataset[location2]", with: "London"
        fill_in "dataset[location3]", with: "England"
        click_button "Save and continue"
      end

      it "should not show date fields or set dates for never" do
        choose option: 'never'
        click_button "Save and continue"

        expect(page).to_not have_content('Start Date')
        expect(page).to_not have_content('End Date')
        expect(page).to_not have_content('Year')

        fill_in 'datafile[url]', with: 'https://localhost/doc'
        fill_in 'datafile[name]', with: 'my test doc'
        click_button "Save and continue"

        expect(Dataset.last.datafiles.last.start_date).to be_nil
        expect(Dataset.last.datafiles.last.end_date).to be_nil
      end

      it "should show no fields for daily and don't set dates" do
        choose option: 'daily'
        click_button "Save and continue"

        expect(page).to_not have_content('Start Date')
        expect(page).to_not have_content('End Date')
        expect(page).to_not have_content('Year')

        fill_in 'datafile[url]', with: 'https://localhost/doc'
        fill_in 'datafile[name]', with: 'my test doc'
        click_button "Save and continue"

        expect(Dataset.last.datafiles.last.start_date).to be_nil
        expect(Dataset.last.datafiles.last.end_date).to be_nil
      end

      it "should show start and end date fields for weekly and set dates" do
        choose option: 'weekly'
        click_button "Save and continue"

        expect(page).to     have_content('Start Date')
        expect(page).to     have_content('End Date')
        expect(page).to_not have_content('Year')

        fill_in 'datafile[url]', with: 'https://localhost/doc'
        fill_in 'datafile[name]', with: 'my test doc'

        # Start Date
        fill_in 'datafile[start_day]',   with: '1'
        fill_in 'datafile[start_month]', with: '1'
        fill_in 'datafile[start_year]',  with: '2020'

        # End Date
        fill_in 'datafile[end_day]',   with: '8'
        fill_in 'datafile[end_month]', with: '1'
        fill_in 'datafile[end_year]',  with: '2020'

        click_button "Save and continue"

        expect(Dataset.last.datafiles.last.start_date).to eq(Date.new(2020, 1, 1))
        expect(Dataset.last.datafiles.last.end_date).to eq(Date.new(2020, 1, 8))
      end

      it "should show start date field for monthly and set dates" do
        choose option: 'monthly'
        click_button "Save and continue"

        expect(page).to_not have_content('Start Date')
        expect(page).to_not have_content('End Date')
        expect(page).to     have_content('Month')
        expect(page).to     have_content('Year')

        fill_in 'datafile[url]', with: 'https://localhost/doc'
        fill_in 'datafile[name]', with: 'my test doc'

        # Start Date
        fill_in 'datafile[start_month]', with: '1'
        fill_in 'datafile[start_year]',  with: '2020'

        click_button "Save and continue"

        expect(Dataset.last.datafiles.last.start_date).to eq(Date.new(2020, 1, 1))
        expect(Dataset.last.datafiles.last.end_date).to eq(Date.new(2020, 1).end_of_month)
      end

      describe "quarters" do
        before(:each) do
          choose option: 'quarterly'
          click_button "Save and continue"

          expect(page).to_not have_content('Start Date')
          expect(page).to_not have_content('End Date')
          expect(page).to_not have_content('Month')
          expect(page).to     have_content('Year')
          expect(page).to     have_content('Quarter')
        end

        def pick_quarter(quarter)
          fill_in 'datafile[url]', with: 'https://localhost/doc'
          fill_in 'datafile[name]', with: 'my test doc'

          choose option: quarter.to_s
          fill_in "datafile[year]", with: Date.today.year
          click_button "Save and continue"
        end

        it "should calculate correct dates for Q1" do
          pick_quarter(1)
          expect(Dataset.last.datafiles.last.start_date).to eq(Date.new(Date.today.year, 4, 1))
          expect(Dataset.last.datafiles.last.end_date).to eq(Date.new(Date.today.year, 6).end_of_month)
        end

        it "should calculate correct dates for Q2" do
          pick_quarter(2)
          expect(Dataset.last.datafiles.last.start_date).to eq(Date.new(Date.today.year, 7, 1))
          expect(Dataset.last.datafiles.last.end_date).to eq(Date.new(Date.today.year, 9).end_of_month)
        end

        it "should calculate correct dates for Q3" do
          pick_quarter(3)
          expect(Dataset.last.datafiles.last.start_date).to eq(Date.new(Date.today.year, 10, 1))
          expect(Dataset.last.datafiles.last.end_date).to eq(Date.new(Date.today.year, 12).end_of_month)
        end

        it "should calculate correct dates for Q4" do
          pick_quarter(4)
          expect(Dataset.last.datafiles.last.start_date).to eq(Date.new(Date.today.year, 1, 1) + 1.year)
          expect(Dataset.last.datafiles.last.end_date).to eq(Date.new(Date.today.year, 3).end_of_month + 1.year)
        end
      end

      def pick_year(year_type)
        choose option: year_type
        click_button "Save and continue"

        expect(page).to_not have_content('Start Date')
        expect(page).to_not have_content('End Date')
        expect(page).to_not have_content('Month')
        expect(page).to     have_content('Year')

        fill_in 'datafile[url]', with: 'https://localhost/doc'
        fill_in 'datafile[name]', with: 'my test doc'

        # Start Date
        fill_in 'datafile[year]',  with: '2015'

        click_button "Save and continue"
      end

      it "should show year field for yearly and set dates" do
        pick_year('annually')
        expect(Dataset.last.datafiles.last.start_date).to eq(Date.new(2015, 1, 1))
        expect(Dataset.last.datafiles.last.end_date).to eq(Date.new(2015, 12).end_of_month)
      end

      it "should show year field for financial year and set dates" do
        pick_year('financial-year')
        expect(Dataset.last.datafiles.last.start_date).to eq(Date.new(2015, 4, 1))
        expect(Dataset.last.datafiles.last.end_date).to eq(Date.new(2016, 3).end_of_month)
      end
    end

    describe "should not be able to start a new draft with invalid inputs" do
      before(:each) do
        visit "/datasets/new"
      end

      it "missing title" do
        fill_in "dataset[summary]", with: "my test dataset summary"
        click_button "Save and continue"
        expect(page).to have_content("There was a problem")
        expect(page).to have_content("Please enter a valid title")
        expect(Dataset.where(title: "my test dataset").length).to eq(0)
      end

      it "missing summary" do
        fill_in "dataset[title]", with: "my test dataset"
        click_button "Save and continue"
        expect(page).to have_content("There was a problem")
        expect(page).to have_content("Please enter a valid summary")
        expect(Dataset.where(title: "my test dataset").length).to eq(0)
      end

      it "missing both" do
        click_button "Save and continue"
        expect(page).to have_content("There was a problem")
        expect(page).to have_content("Please enter a valid title")
        expect(page).to have_content("Please enter a valid summary")
        expect(Dataset.where(title: "my test dataset").length).to eq(0)
      end
    end
  end
end
