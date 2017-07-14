require 'uri'

class DateConstructionValidator < ActiveModel::Validator
  def validate(record)
    return if record.documentation

    if record.dataset.weekly?
      ok_start_day = validate_start_day(record)
      ok_start_month = validate_start_month(record)
      ok_start_year = validate_start_year(record)
      ok_end_day = validate_end_day(record)
      ok_end_month = validate_end_year(record)
      ok_end_year = validate_end_month(record)

      if (ok_start_day && ok_start_month && ok_start_year)
        validate_start_date(record)
      end

      if (ok_end_day && ok_end_month && ok_end_year)
        validate_end_date(record)
      end
    elsif record.dataset.monthly?
      validate_start_month(record)
      validate_start_year(record)
    elsif record.dataset.financial_yearly? || record.dataset.annually?
      validate_start_year(record)
    elsif record.dataset.quarterly?
      validate_start_year(record)
    end
  end


  private
  def validate_start_date(record)
    if record.dataset.monthly? || record.dataset.weekly?
      begin
        Date.new(record.start_year.to_i, record.start_month.to_i, (record.start_day || 1).to_i)
      rescue ArgumentError
        record.errors[:start_date] << (record.dataset.weekly? ? "Please enter a valid start date" : "Please enter a valid date")
      end
    end
  end

  def validate_end_date(record)
    if record.dataset.weekly?
      begin
        Date.new(record.end_year.to_i, record.end_month.to_i, record.end_day.to_i)
      rescue ArgumentError
        record.errors[:end_date] << "Please enter a valid end date"
      end
    end
  end

  def validate_start_year(record)
    start_year = record.start_year.to_i
    if record.start_year && (start_year < 1000 || start_year > 5000)
      record.errors[:start_year] << (record.dataset.weekly? ? "Please enter a valid start year" : "Please enter a valid year")
      return false
    end
    return true
  end
  def validate_end_year(record)
    end_year = record.end_year.to_i
    if record.end_year && (end_year < 1000 || end_year > 5000)
      record.errors[:end_year] << "Please enter a valid end year"
      return false
    end
    return true
  end
  def validate_start_month(record)
    start_month = record.start_month.to_i
    if record.start_month && (start_month < 1 || start_month > 12)
      record.errors[:start_month] << (record.dataset.weekly? ? "Please enter a valid start month" : "Please enter a valid month")
      return false
    end
    return true
  end
  def validate_end_month(record)
    end_month = record.end_month.to_i
    if record.end_month && (end_month < 1 || end_month > 12)
      record.errors[:end_month] << "Please enter a valid end month"
      return false
    end
    return true
  end
  def validate_start_day(record)
    start_day = record.start_day.to_i
    if record.start_day && (start_day < 1 || start_day > 31)
      record.errors[:start_day] << (record.dataset.weekly? ? "Please enter a valid start day" : "Please enter a valid day")
      return false
    end
    return true
  end
  def validate_end_day(record)
    end_day = record.end_day.to_i
    if record.end_day && (end_day < 1 || end_day > 31)
      record.errors[:end_day] << "Please enter a valid end day"
      return false
    end
    return true
  end
end

class Datafile < ApplicationRecord
  attr_accessor :start_day, :start_month, :start_year,
    :end_day, :end_month, :end_year

  belongs_to :dataset
  before_save :set_dates

  validates :url, presence: { message: 'Please enter a valid URL' }
  validates :name, presence: { message: 'Please enter a valid name' }

  # Quarterly
  validates :quarter,
    presence: { message: "Please select a quarter" },
    if: -> { !self.documentation && self.dataset.quarterly? }

  scope :published, -> { where(published: true) }
  scope :draft,     -> { where(published: false) }

  scope :datalinks,     -> { where(documentation: [false, nil]) }
  scope :documentation, -> { where(documentation: true) }

  validates_with DateConstructionValidator

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
