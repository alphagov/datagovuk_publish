class DatafileDateParser
  attr_reader :datafile

  def initialize(datafile)
    @datafile = datafile
  end

  def start_and_end_dates
    return weekly_dates           if datafile.dataset.weekly?
    return monthly_dates          if datafile.dataset.monthly?
    return quarterly_dates        if datafile.dataset.quarterly?
    return yearly_dates           if datafile.dataset.annually?
    return financial_yearly_dates if datafile.dataset.financial_yearly?
  end

  def weekly_dates
    [date_start, date_end]
  end

  def monthly_dates
    [
      date_start,
      datafile.start_date.end_of_month
    ]
  end

  def quarterly_dates
    [
      quarter_to_date,
      (datafile.start_date + 2.months).end_of_month
    ]
  end

  def yearly_dates
    [
      Date.new(datafile.start_year.to_i),
      Date.new(datafile.start_year.to_i, 12).end_of_month
    ]
  end

  def financial_yearly_dates
    [
      Date.new(datafile.start_year.to_i, 4, 1),
      Date.new(datafile.start_year.to_i + 1, 3).end_of_month
    ]
  end

  private

  def date_start
    if datafile.dataset.monthly?
      datafile.start_day = 1
    end

    Date.new(datafile.start_year.to_i,
             datafile.start_month.to_i,
             datafile.start_day.to_i)
  end

  def date_end
    Date.new(datafile.end_year.to_i,
             datafile.end_month.to_i,
             datafile.end_day.to_i)
  end

  def quarter_to_date
    year_start = Date.new(datafile.start_year.to_i, 1, 1)
    quarter_offset = 4 + (datafile.quarter.to_i - 1) * 3 # Q1: 4, Q2: 7, Q3: 10, Q4: 13
    year_start + (quarter_offset - 1).months
  end
end
