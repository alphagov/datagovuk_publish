class Datafile < Link
  attr_accessor :day, :month, :year

  # Some legacy datafiles have invalid dates (e.g. 31/06/15)
  # When this occurs the date attributes are not set.
  # Validations are skipped when importing, therefore it is possible
  # to save a datafile with no start or end dates

  before_save :set_end_date, unless: -> { year.nil? }
  before_save :set_start_date, unless: -> { year.nil? }

  validate  :validate_date_input, unless: -> { dataset.never? }
  validates :quarter, presence: true, if: -> { dataset.quarterly? }

  def dates
    {
      day: day || end_date&.day,
      month: month || end_date&.month,
      year: year || end_date&.year,
    }.with_indifferent_access
  end

  def set_end_date
    self.end_date = compute_date(:end)
  end

  def set_start_date
    self.start_date = compute_date(:start)
  end

private

  def compute_date(date_type)
    return daily_date                       if dataset.daily?
    return monthly_date(date_type)          if dataset.monthly?
    return quarterly_date(date_type)        if dataset.quarterly?
    return yearly_date(date_type)           if dataset.annually?

    financial_yearly_date(date_type) if dataset.financial_yearly?
  end

  def daily_date
    Date.new(year.to_i, month.to_i, day.to_i)
  end

  def monthly_date(date_type)
    if date_type == :end
      Date.new(year.to_i, month.to_i).end_of_month
    else
      Date.new(year.to_i, month.to_i).beginning_of_month
    end
  end

  def quarterly_date(date_type)
    if date_type == :end
      (quarter_to_date + 2.months).end_of_month
    else
      (quarter_to_date + 2.months).beginning_of_month
    end
  end

  def quarter_to_date
    year_start = Date.new(year.to_i).beginning_of_year
    year_start + (quarter_offset - 1).months
  end

  def quarter_offset
    4 + (quarter.to_i - 1) * 3 # Q1: 4, Q2: 7, Q3: 10, Q4: 13
  end

  def yearly_date(date_type)
    if date_type == :end
      Date.new(year.to_i).end_of_year
    else
      Date.new(year.to_i).beginning_of_year
    end
  end

  def financial_yearly_date(date_type)
    if date_type == :end
      Date.new(year.to_i + 1).end_of_quarter
    else
      Date.new(year.to_i + 1).beginning_of_quarter
    end
  end

  def validate_date_input
    validate_date  if dataset.daily?
    validate_month if dataset.daily? || dataset.monthly?
    validate_year
  end

  def validate_date
    if (
      begin
        daily_date
      rescue StandardError
        ArgumentError
      end) == ArgumentError
      errors.add(:date, "Please enter a valid date")
    end
  end

  def validate_month
    if month.to_i < 1 || month.to_i > 12
      errors.add(:month, "Please enter a valid month")
    end
  end

  def validate_year
    if year.to_i < 1000 || year.to_i > 5000
      errors.add(:year, "Please enter a valid year")
    end
  end
end
