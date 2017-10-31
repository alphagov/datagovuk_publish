class Link < Datafile
  attr_accessor :start_day, :start_month, :start_year,
                :end_day,   :end_month,   :end_year

  before_save :set_dates

  validate  :dates_valid, unless: ->{ documentation? }
  validates :quarter, presence: true, if: ->{ !documentation && dataset.quarterly? }

  def dates
    {
      start: {
        day:   start_day.presence   || start_date&.day,
        month: start_month.presence || start_date&.month,
        year:  start_year.presence  || start_date&.year
      },
      end: {
        day:   end_day   || end_date&.day,
        month: end_month || end_date&.month,
        year:  end_year  || end_date&.year
      }
    }.with_indifferent_access
  end

  def set_dates
    self.start_date, self.end_date = start_and_end_dates
  end

  private

  def start_and_end_dates
    return weekly_dates           if dataset.weekly?
    return monthly_dates          if dataset.monthly?
    return quarterly_dates        if dataset.quarterly?
    return yearly_dates           if dataset.annually?
    return financial_yearly_dates if dataset.financial_yearly?
  end

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

  def quarter_offset
    4 + (quarter.to_i - 1) * 3 # Q1: 4, Q2: 7, Q3: 10, Q4: 13
  end

  def dates_valid
    validate_days
    validate_months
    validate_years
    validate_start_date if dataset.monthly? || dataset.weekly?
    validate_end_date   if dataset.weekly?
  end

  def validate_days
    days.compact.each do |attr, day|
      if day.to_i < 1 || day.to_i > 31
        errors.add(attr, "Please enter a valid #{attr.to_s.humanize.downcase}")
      end
    end
  end

  def validate_months
    months.compact.each do |attr, month_number|
      if month_number.to_i < 1 || month_number.to_i > 12
        attr = "month" if dataset.monthly?
        errors.add(attr, "Please enter a valid #{attr.to_s.humanize.downcase}")
      end
    end
  end

  def validate_years
    years.compact.each do |attr, year|
      if year.to_i < 1000 || year.to_i > 5000
        attr = "year" unless dataset.weekly?
        errors.add(attr, "Please enter a valid #{attr.to_s.humanize.downcase}")
      end
    end
  end

  def validate_start_date
    if (date_start rescue ArgumentError) == ArgumentError
      period = "start" if dataset.weekly?
      errors.add(:start_date, "Please enter a valid #{period} date".squish)
    end
  end

  def validate_end_date
    if (date_end rescue ArgumentError) == ArgumentError
      period = "end" if dataset.weekly?
      errors.add(:end_date, "Please enter a valid #{period} date".squish)
    end
  end

  def days
    { start_day: start_day, end_day: end_day }.compact
  end

  def months
    { start_month: start_month, end_month: end_month }.compact
  end

  def years
    { start_year: start_year, end_year: end_year }.compact
  end
end
