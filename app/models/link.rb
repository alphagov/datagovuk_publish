class Link < Datafile

  before_save :set_end_date

  validate  :validate_date_input, unless: ->{ dataset.never? || start_date.nil? }
  validates :quarter, presence: true, if: ->{ dataset.quarterly? }

  def start_date
    self['start_date']
  end

  def set_end_date
    if start_date
      self.end_date = compute_date
    end
  end

  private

  def compute_date
    return daily_date            if dataset.daily?
    return monthly_date          if dataset.monthly?
    return quarterly_date        if dataset.quarterly?
    return yearly_date           if dataset.annually?
    return financial_yearly_date if dataset.financial_yearly?
  end

  def daily_date
    Date.new(start_date.year.to_i, start_date.month.to_i, start_date.day)
  end

  def monthly_date
    Date.new(start_date.year.to_i, start_date.month.to_i).end_of_month
  end

  def quarterly_date
    (quarter_to_date + 2.months).end_of_month
  end

  def quarter_to_date
    year_start = Date.new(start_date.year.to_i).beginning_of_year
    year_start + (quarter_offset - 1).months
  end

  def quarter_offset
    4 + (quarter.to_i - 1) * 3 # Q1: 4, Q2: 7, Q3: 10, Q4: 13
  end

  def yearly_date
    Date.new(start_date.year.to_i).end_of_year
  end

  def financial_yearly_date
    Date.new(start_date.year.to_i + 1).end_of_quarter
  end

  def validate_date_input
    validate_date  if dataset.daily?
    validate_month if dataset.daily? || dataset.monthly?
    validate_year
  end

  def validate_date
    if (daily_date rescue ArgumentError) == ArgumentError
      errors.add(:date, 'Please enter a valid date')
    end
  end

  def validate_month
    if start_date.month.to_i < 1 || start_date.month.to_i > 12
      errors.add(:month, 'Please enter a valid month')
    end
  end

  def validate_year
    if start_date.year.to_i < 1000 || start_date.year.to_i > 5000
      errors.add(:year, 'Please enter a valid year')
    end
  end
end
