require "rails_helper"

describe "creating datasets" do
  set_up

  before(:each) do
    sign_in
  end

  describe 'unfinished datasets' do
    it 'should be able to show an unfinished dataset' do
      click_link 'Manage datasets'
      expect(page).to have_content(unfinished_dataset.title)
      visit '/datasets/test-title-unfinished'
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

      # Ensure the dataset is indexed in Elastic
      client = Dataset.__elasticsearch__.client
      document = client.get({ index: Dataset.index_name, id: Dataset.last.id })
      expect(document["_source"]["name"]).to eq("my-test-dataset")

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

      it "should fail with an error when no date is set" do
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

      context "should show an error if no date is entered" do
        it "weekly" do
          choose option: 'weekly'
          click_button "Save and continue"

          expect(page).to     have_content('Start Date')
          expect(page).to     have_content('End Date')
          expect(page).to_not have_content('Year')

          fill_in 'datafile[url]', with: 'https://localhost/doc'
          fill_in 'datafile[name]', with: 'my test doc'

          click_button "Save and continue"

          expect(page).to have_content("There was a problem")
          expect(page).to have_content("Please enter a valid start day")
          expect(page).to have_content("Please enter a valid start month")
          expect(page).to have_content("Please enter a valid start year")
          expect(page).to have_content("Please enter a valid end day")
          expect(page).to have_content("Please enter a valid end month")
          expect(page).to have_content("Please enter a valid end year")
        end

        it "monthly" do
          choose option: 'monthly'
          click_button "Save and continue"

          expect(page).to_not have_content('Start Date')
          expect(page).to_not have_content('End Date')
          expect(page).to     have_content('Month')
          expect(page).to     have_content('Year')

          fill_in 'datafile[url]', with: 'https://localhost/doc'
          fill_in 'datafile[name]', with: 'my test doc'

          click_button "Save and continue"

          expect(page).to have_content("There was a problem")
          expect(page).to have_content("Please enter a valid month")
          expect(page).to have_content("Please enter a valid year")
        end
      end

      context "should show an error if a date is invalid, but individual fields are" do
        it "weekly" do
          choose option: 'weekly'
          click_button "Save and continue"

          expect(page).to     have_content('Start Date')
          expect(page).to     have_content('End Date')
          expect(page).to_not have_content('Year')

          fill_in 'datafile[url]', with: 'https://localhost/doc'
          fill_in 'datafile[name]', with: 'my test doc'

          fill_in 'datafile[start_day]', with: '30'
          fill_in 'datafile[start_month]', with: '02'
          fill_in 'datafile[start_year]',  with: '2020'

          fill_in 'datafile[end_day]', with: '30'
          fill_in 'datafile[end_month]', with: '03'
          fill_in 'datafile[end_year]',  with: '2020'


          click_button "Save and continue"

          expect(page).to have_content("There was a problem")
          expect(page).to_not have_content("Please enter a valid day")
          expect(page).to_not have_content("Please enter a valid month")
          expect(page).to_not have_content("Please enter a valid year")
          expect(page).to have_content("Please enter a valid start date")
        end
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
          fill_in "datafile[start_year]", with: Date.today.year
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
        fill_in 'datafile[start_year]',  with: '2015'

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
        expect(page).to have_content("Please enter a valid title", count: 2)
        page.should have_selector("div", :class => "form-group-error")
        expect(Dataset.where(title: "my test dataset").length).to eq(0)
        # recover
        fill_in "dataset[title]", with: "my test dataset"
        fill_in "dataset[summary]", with: "my test dataset summary"
        fill_in "dataset[description]", with: "my test dataset description"
        click_button "Save and continue"
        expect(page).to have_content("Choose a licence")
      end

      it "missing summary" do
        fill_in "dataset[title]", with: "my test dataset"
        click_button "Save and continue"
        expect(page).to have_content("There was a problem")
        expect(page).to have_content("Please provide a summary", count: 2)
        page.should have_selector("div", :class => "form-group-error")
        expect(Dataset.where(title: "my test dataset").length).to eq(0)
        # recover
        fill_in "dataset[title]", with: "my test dataset"
        fill_in "dataset[summary]", with: "my test dataset summary"
        fill_in "dataset[description]", with: "my test dataset description"
        click_button "Save and continue"
        expect(page).to have_content("Choose a licence")
      end

      it "missing both title and summary" do
        click_button "Save and continue"
        expect(page).to have_content("There was a problem")
        expect(page).to have_content("Please enter a valid title", count: 2)
        expect(page).to have_content("Please provide a summary", count: 2)
        expect(Dataset.where(title: "my test dataset").length).to eq(0)
        # recover
        fill_in "dataset[title]", with: "my test dataset"
        fill_in "dataset[summary]", with: "my test dataset summary"
        fill_in "dataset[description]", with: "my test dataset description"
        click_button "Save and continue"
        expect(page).to have_content("Choose a licence")
      end

      describe "should pass the licence screen" do
        before(:each) do
          fill_in "dataset[title]", with: "my test dataset"
          fill_in "dataset[summary]", with: "my test dataset summary"
          fill_in "dataset[description]", with: "my test dataset description"
          click_button "Save and continue"
          expect(page).to have_content("Choose a licence")
        end

        it "works when selecting OGL" do
          choose option: "uk-ogl"
          click_button "Save and continue"
          expect(page).to have_content("Choose a geographical area")
        end

        it "missing a licence, continue anyway" do
          click_button "Save and continue"
          expect(page).to have_content("Choose a geographical area")
        end

        it "skips licence" do
          click_link "Skip this step"
          expect(page).to have_content("Choose a geographical area")
        end

        it "selected other licence but didn't specify" do
          choose option: "other"
          click_button "Save and continue"
          expect(page).to have_content("Please type the name of your licence", count: 2)
          fill_in "dataset[licence_other]", with: "MIT"
          click_button "Save and continue"
          expect(page).to have_content("Choose a geographical area")
        end

        describe "should pass the geographical area page" do
          before(:each) do
            choose option: "uk-ogl"
            click_button "Save and continue"
          end

          it "allow entering a geographical area" do
            fill_in "dataset[location1]", with: "High Wycombe"
            click_button "Save and continue"
            expect(page).to have_content("How frequently is this dataset updated?")
          end

          it "allow not entering a geographical area" do
            click_button "Save and continue"
            expect(page).to have_content("How frequently is this dataset updated?")
          end

          describe "should pass the frequency page" do
            before(:each) do
              fill_in "dataset[location1]", with: "High Wycombe"
              click_button "Save and continue"
            end

            it "should continue once user specifies a frequency" do
              choose option: "never"
              click_button "Save and continue"
              expect(page).to have_content("Add a link to your data")
            end

            it "should mandate entering a frequency" do
              click_button "Save and continue"
              expect(page).to have_content("Please indicate how often this dataset is updated", count: 2)
              choose option: "never"
              click_button "Save and continue"
              expect(page).to have_content("Add a link to your data")
            end

            it "should route to the daily datafiles page and check for errors" do
              choose option: "daily"
              click_button "Save and continue"
              expect(page).to have_content("Add a link to your data")
              expect(page).to_not have_content("Year")
              click_button "Save and continue"
              expect(page).to have_content("Please enter a valid URL", count: 2)
              expect(page).to have_content("Please enter a valid name", count: 2)
              fill_in "datafile[url]", with: "http://www.example.com/test.csv"
              fill_in "datafile[name]", with: "Test datafile"
              click_button "Save and continue"
              expect(page).to have_content("Links to your data")
            end

            it "should route to the one-off datafiles page" do
              choose option: "never"
              click_button "Save and continue"
              expect(page).to have_content("Add a link to your data")
              expect(page).to_not have_content("Year")
            end

            it "should route to the weekly datafiles page and check for errors" do
              choose option: "weekly"
              click_button "Save and continue"
              expect(page).to have_content("Add a link to your data")
              expect(page).to have_content("Start Date")
              expect(page).to have_content("End Date")
              fill_in "datafile[url]", with: "http://www.example.com/test.csv"
              fill_in "datafile[name]", with: "Test datafile"
              click_button "Save and continue"
              expect(page).to have_content("Please enter a valid start day", count: 2)
              expect(page).to have_content("Please enter a valid start month", count: 2)
              expect(page).to have_content("Please enter a valid start year", count: 2)
              expect(page).to have_content("Please enter a valid end day", count: 2)
              expect(page).to have_content("Please enter a valid end month", count: 2)
              expect(page).to have_content("Please enter a valid end year", count: 2)
              fill_in "datafile[start_day]", with: "234"
              fill_in "datafile[start_month]", with: "June"
              fill_in "datafile[start_year]", with: "234"
              fill_in "datafile[end_day]", with: "234"
              fill_in "datafile[end_month]", with: "234"
              fill_in "datafile[end_year]", with: "234"
              click_button "Save and continue"
              expect(page).to have_content("Please enter a valid start day", count: 2)
              expect(page).to have_content("Please enter a valid start month", count: 2)
              expect(page).to have_content("Please enter a valid start year", count: 2)
              expect(page).to have_content("Please enter a valid end day", count: 2)
              expect(page).to have_content("Please enter a valid end month", count: 2)
              expect(page).to have_content("Please enter a valid end year", count: 2)
              fill_in "datafile[start_day]", with: "31"
              fill_in "datafile[start_month]", with: "02"
              fill_in "datafile[start_year]", with: "2019"
              fill_in "datafile[end_day]", with: "31"
              fill_in "datafile[end_month]", with: "05"
              fill_in "datafile[end_year]", with: "2019"
              click_button "Save and continue"
              expect(page).to_not have_content("Please enter a valid start day")
              expect(page).to_not have_content("Please enter a valid start month", count: 2)
              expect(page).to_not have_content("Please enter a valid start year", count: 2)
              expect(page).to_not have_content("Please enter a valid end day", count: 2)
              expect(page).to_not have_content("Please enter a valid end month", count: 2)
              expect(page).to_not have_content("Please enter a valid end year", count: 2)
              expect(page).to have_content("Please enter a valid start date", count: 2)
              fill_in "datafile[start_month]", with: "01"
              click_button "Save and continue"
              expect(page).to have_content("Links to your data")
            end

            it "should route to the monthly datafiles page and check for errors" do
              choose option: "monthly"
              click_button "Save and continue"
              expect(page).to have_content("Add a link to your data")
              expect(page).to have_content("Time period for this link")
              fill_in "datafile[url]", with: "http://www.example.com/test.csv"
              fill_in "datafile[name]", with: "Test datafile"
              click_button "Save and continue"
              expect(page).to have_content("Please enter a valid month", count: 2)
              expect(page).to have_content("Please enter a valid year", count: 2)
              fill_in "datafile[start_month]", with: "01"
              fill_in "datafile[start_year]", with: "2019"
              click_button "Save and continue"
              expect(page).to have_content("Links to your data")
            end

            it "should route to the quarterly datafiles page and check for errors" do
              choose option: "quarterly"
              click_button "Save and continue"
              expect(page).to have_content("Add a link to your data")
              expect(page).to have_content("Quarter")
              fill_in "datafile[url]", with: "http://www.example.com/test.csv"
              fill_in "datafile[name]", with: "Test datafile"
              click_button "Save and continue"
              expect(page).to have_content("Please select a quarter", count: 2)
              expect(page).to have_content("Please enter a valid year", count: 2)
              choose option: "2"
              fill_in "datafile[start_year]", with: "2019"
              click_button "Save and continue"
              expect(page).to have_content("Links to your data")
            end

            it "should route to the yearly datafiles page and check for errors" do
              choose option: "annually"
              click_button "Save and continue"
              expect(page).to have_content("Add a link to your data")
              expect(page).to have_content("Time period for this link")
              expect(page).to_not have_content("Month")
              expect(page).to have_content("Year")
              fill_in "datafile[url]", with: "http://www.example.com/test.csv"
              fill_in "datafile[name]", with: "Test datafile"
              click_button "Save and continue"
              expect(page).to have_content("Please enter a valid year", count: 2)
              fill_in "datafile[start_year]", with: "2019"
              click_button "Save and continue"
              expect(page).to have_content("Links to your data")
            end

            it "should route to the yearly (financial) datafiles page and check for errors" do
              choose option: "financial-year"
              click_button "Save and continue"
              expect(page).to have_content("Add a link to your data")
              expect(page).to have_content("Time period for this link")
              expect(page).to_not have_content("Month")
              expect(page).to have_content("Year")
              fill_in "datafile[url]", with: "http://www.example.com/test.csv"
              fill_in "datafile[name]", with: "Test datafile"
              click_button "Save and continue"
              expect(page).to have_content("Please enter a valid year", count: 2)
              fill_in "datafile[start_year]", with: "2019"
              click_button "Save and continue"
              expect(page).to have_content("Links to your data")
            end
          end
        end
      end
    end
  end
end
