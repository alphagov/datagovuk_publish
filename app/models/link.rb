require 'validators/date_validator'

class Link < Datafile
  attr_accessor :start_day, :start_month, :start_year,
    :end_day, :end_month, :end_year

  before_save :set_dates

  validates :quarter, presence: true,
    if: -> { !self.documentation && self.dataset.quarterly? }
  validates_with DateValidator

  def dates
    {
      start: {
        day: start_day,
        month: start_month,
        year: start_year
      },
      end: {
        day: end_day,
        month: end_month,
        year: end_year
      }
    }.with_indifferent_access
  end

  private
  def set_dates
    return if self.documentation

    set_weekly_dates           if dataset.weekly?
    set_monthly_dates          if dataset.monthly?
    set_quarterly_dates        if dataset.quarterly?
    set_yearly_dates           if dataset.annually?
    set_financial_yearly_dates if dataset.financial_yearly?
  end

  def set_weekly_dates
    self.start_date = date_start
    self.end_date = date_end
  end

  def set_monthly_dates
    self.start_date = date_start
    self.end_date = self.start_date.end_of_month
  end

  def set_quarterly_dates
    self.start_date = quarter_to_date
    self.end_date = (self.start_date + 2.months).end_of_month
  end

  def set_yearly_dates
    self.start_date = Date.new(self.start_year.to_i)
    self.end_date = Date.new(self.start_year.to_i, 12).end_of_month
  end

  def set_financial_yearly_dates
    self.start_date = Date.new(self.start_year.to_i, 4, 1)
    self.end_date = Date.new(self.start_year.to_i + 1, 3).end_of_month
  end

  def date_start
    if self.dataset.monthly?
      self.start_day = 1
    end

    Date.new(self.start_year.to_i,
             self.start_month.to_i,
             self.start_day.to_i)
  end

  def date_end
    Date.new(self.end_year.to_i,
             self.end_month.to_i,
             self.end_day.to_i)
  end

  def quarter_to_date
    year_start = Date.new(self.start_year.to_i, 1, 1)
    quarter_offset = 4 + (self.quarter.to_i - 1) * 3 # Q1: 4, Q2: 7, Q3: 10, Q4: 13
    year_start + (quarter_offset - 1).months
  end
end
