require 'rails_helper'

describe Datafile, type: :model do
  DAILY = 'daily'.freeze
  MONTHLY = 'monthly'.freeze
  ANNUALLY = 'annually'.freeze

  before do
    @datafile = FactoryGirl.create(:datafile)
  end

  describe 'creation' do
    it 'can be created' do
      expect(@datafile).to be_valid
    end
  end

  describe 'date validation' do
    describe "associated dataset has frequency: #{ANNUALLY}" do
      before(:each) do
        @datafile.dataset.frequency = ANNUALLY
      end

      it 'is valid' do
        valid_year = '2016'
        @datafile.year = valid_year
        @datafile.month = '06'
        @datafile.day = '01'

        expect(@datafile).to be_valid
      end

      it 'is not valid' do
        invalid_year_less_than1000 = '999'
        invalid_year_greater_than5000 = '5001'

        @datafile.year = invalid_year_less_than1000
        @datafile.month = '06'
        @datafile.day = '01'

        expect(@datafile).to_not be_valid

        @datafile.year = invalid_year_greater_than5000

        expect(@datafile).to_not be_valid
      end
    end

    describe "associated dataset has frequency: #{MONTHLY}" do
      before(:each) do
        @datafile.dataset.frequency = MONTHLY
      end

      it 'is valid' do
        valid_month = '03'

        @datafile.year = '2016'
        @datafile.month = valid_month
        @datafile.day = '12'

        expect(@datafile).to be_valid
      end

      it 'is not valid' do
        invalid_month_greater_than12 = 13
        invalid_month_less_than1 = 0

        @datafile.year = '2016'
        @datafile.month = invalid_month_greater_than12
        @datafile.day = '12'

        expect(@datafile).to_not be_valid

        @datafile.month = invalid_month_less_than1

        expect(@datafile).to_not be_valid
      end
    end

    describe "associated dataset has frequency #{DAILY}" do
      before(:each) do
        @datafile.dataset.frequency = DAILY
      end

      it 'is valid' do
        valid_day = '03'

        @datafile.year = '2016'
        @datafile.month = '06'
        @datafile.day = valid_day

        expect(@datafile).to be_valid
      end

      it 'is not valid' do
        invalid_day = 31

        @datafile.year = '2016'
        @datafile.month = '06'
        @datafile.day = invalid_day

        expect(@datafile).to_not be_valid

      end
    end
  end

  describe 'before saving' do
    before(:each) do
      @datafile.dataset.frequency = ANNUALLY
    end

    it 'sets an end date if year is not nil' do
      @datafile.year = '2016'
      @datafile.end_date = nil

      @datafile.save!

      expect(Datafile.last.end_date).to_not be_nil
    end

    it 'sets a start date if year is not nil' do
      @datafile.year = '2016'
      @datafile.start_date = nil

      @datafile.save!

      expect(Datafile.last.start_date).to_not be_nil
    end

    describe 'Importing legacy datasets' do
      # Some legacy datafiles have invalid dates (e.g. 31/06/15)
      # When this occurs the date attributes are not set
      # Validations are skipped when importing, therefore it is possible
      # to save a datafile with no start or end dates

      before(:each) do
        @datafile.dataset.frequency = ANNUALLY
      end

      it 'does not set an end date if year is nil' do
        @datafile.year = nil
        @datafile.end_date = nil

        @datafile.save(validate: false)

        expect(Datafile.last.end_date).to be_nil
      end

      it 'does not set a start date if year is nil' do
        @datafile.year = nil
        @datafile.start_date = nil

        @datafile.save(validate: false)

        expect(Datafile.last.start_date).to be_nil
      end
    end
  end
end
