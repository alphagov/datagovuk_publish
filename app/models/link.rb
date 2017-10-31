class Link < Datafile
  attr_accessor :date_fields

  validate  :dates_valid
  validates :quarter, presence: true, if: ->{ dataset.quarterly? }

  def dates
    {
      start: {
        day:   start_day   || start_date&.day,
        month: start_month || start_date&.month,
        year:  start_year  || start_date&.year
      },
      end: {
        day:   end_day   || end_date&.day,
        month: end_month || end_date&.month,
        year:  end_year  || end_date&.year
      }
    }.with_indifferent_access
  end

  def start_and_end_dates
    return weekly_dates           if dataset.weekly?
    return monthly_dates          if dataset.monthly?
    return quarterly_dates        if dataset.quarterly?
    return yearly_dates           if dataset.annually?
    return financial_yearly_dates if dataset.financial_yearly?
  end

  private

  def weekly_dates
    [date_start, date_end]
  end

  def monthly_dates
    [
      date_start,
      date_start.end_of_month
    ]
  end

  def quarterly_dates
    [
      quarter_to_date,
      (quarter_to_date + 2.months).end_of_month
    ]
  end

  def yearly_dates
    [
      Date.new(start_year.to_i),
      Date.new(start_year.to_i, 12).end_of_month
    ]
  end

  def financial_yearly_dates
    [
      Date.new(start_year.to_i, 4, 1),
      Date.new(start_year.to_i + 1, 3).end_of_month
    ]
  end

  private

  def date_start
    Date.new(start_year.to_i,
             start_month.to_i,
             start_day.to_i)
  end

  def date_end
    Date.new(end_year.to_i,
             end_month.to_i,
             end_day.to_i)
  end

  def quarter_to_date
    year_start = Date.new(start_year.to_i).beginning_of_year
    year_start + (quarter_offset - 1).months
  end

  def start_day
    return if date_fields.nil?
    date_fields[:days][:start]
  end

  def start_month
    return if date_fields.nil?
    date_fields[:months][:start]
  end

  def start_year
    return if date_fields.nil?
    date_fields[:years][:start]
  end

  def end_day
    return if date_fields.nil?
    date_fields[:days][:end]
  end

  def end_month
    return if date_fields.nil?
    date_fields[:months][:end]
  end

  def end_year
    return if date_fields.nil?
    date_fields[:years][:end]
  end

  def quarter_offset
    4 + (quarter.to_i - 1) * 3 # Q1: 4, Q2: 7, Q3: 10, Q4: 13
  end

  def dates_valid
    date_fields[:days].compact.each do |attr, day|
      if day.to_i < 1 || day.to_i > 31
        errors.add(attr, "Please enter a valid #{attr} day")
      end
    end

    date_fields[:months].compact.each do |attr, month_number|
      if month_number.to_i < 1 || month_number.to_i > 12
        attr = "" if dataset.monthly?
        errors.add(attr, "Please enter a valid #{attr} month")
      end
    end

    date_fields[:years].compact.each do |attr, year|
      if year.to_i < 1000 || year.to_i > 5000
        attr = "" if dataset.monthly?
        errors.add(attr, "Please enter a valid #{attr} year")
      end
    end
  end
end
