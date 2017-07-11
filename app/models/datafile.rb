require 'uri'

class DateConstructionValidator < ActiveModel::Validator
  def validate(record)
    return if record.documentation

    start_year = record.start_year.to_i
    if record.start_year && (start_year < 1000 || start_year > 5000)
      record.errors[:start_year] << "Please enter a valid year"
    end
    start_month = record.start_month.to_i
    if record.start_month && (start_month < 1 || start_month > 12)
      record.errors[:start_month] << "Please enter a valid month"
    end
    start_day = record.start_day.to_i
    if record.start_day && (start_day < 1 || start_day > 31)
      record.errors[:start_day] << "Please enter a valid day"
    end
    end_year = record.end_year.to_i
    if record.end_year && (end_year < 1000 || end_year > 5000)
      record.errors[:end_year] << "Please enter a valid year"
    end
    end_month = record.end_month.to_i
    if record.end_month &&  (end_month < 1 || end_month > 12)
      record.errors[:end_month] << "Please enter a valid month"
    end
    end_day = record.end_day.to_i
    if record.end_day && (end_day < 1 || end_day > 31)
      record.errors[:end_day] << "Please enter a valid day"
    end
    year = record.year.to_i
    if record.year && (year < 1000 || year > 5000)
      record.errors[:year] << "Please enter a valid year"
    end

    if record.dataset.monthly? || record.dataset.weekly?
      begin
        Date.new(record.start_year.to_i, record.start_month.to_i, (record.start_day || 1).to_i)
      rescue ArgumentError
        record.errors[:start_date] << "Please enter a valid start date"
      end
    end

    if record.dataset.weekly?
      begin
        Date.new(record.end_year.to_i, record.end_month.to_i, record.end_day.to_i)
      rescue ArgumentError
        record.errors[:end_date] << "Please enter a valid end date"
      end
    end
  end
end

class Datafile < ApplicationRecord
  attr_accessor :start_day, :start_month, :start_year,
    :end_day, :end_month, :end_year

  belongs_to :dataset
  before_save :set_dates

  validates :url, presence: true
  validates :name, presence: true

  # Weekly & Monthly
  validates :start_month, presence: true, if: -> { !self.documentation && (self.dataset.weekly? || self.dataset.monthly?) }
  validates :start_year,  presence: true, if: -> { !self.documentation && (self.dataset.weekly? || self.dataset.monthly?) }

  # Weekly
  validates :start_day,  presence: true, if: -> { !self.documentation && self.dataset.weekly? }
  validates :end_day,   presence: true, if: -> { !self.documentation && self.dataset.weekly? }
  validates :end_month, presence: true, if: -> { !self.documentation && self.dataset.weekly? }
  validates :end_year,  presence: true, if: -> { !self.documentation && self.dataset.weekly? }

  # Quarterly
  validates :quarter, presence: true, inclusion: { in: 1..4 }, if: -> { !self.documentation && self.dataset.quarterly? }

  # Yearly & Quarterly
  validates :year, presence: true, if: -> { !self.documentation && (self.dataset.annually? || self.dataset.quarterly? || self.dataset.financial_yearly?) }

  scope :published, -> { where(published: true) }
  scope :draft,     -> { where(published: false) }

  scope :datalinks,     -> { where(documentation: [false, nil]) }
  scope :documentation, -> { where(documentation: true) }

  validates_with DateConstructionValidator

  def dates
    {
      start: {
        day: start_date.try(:day),
        month: start_date.try(:month),
        year: start_date.try(:year)
      },
      end: {
        day: end_date.try(:day),
        month: end_date.try(:month),
        year: end_date.try(:year)
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
    self.start_date = Date.new(self.year.to_i)
    self.end_date = Date.new(self.year.to_i, 12).end_of_month
  end

  def set_financial_yearly_dates
    self.start_date = Date.new(self.year.to_i, 4, 1)
    self.end_date = Date.new(self.year.to_i + 1, 3).end_of_month
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
    year_start = Date.new(self.year.to_i, 1, 1)
    quarter_offset = 4 + (self.quarter.to_i - 1) * 3 # Q1: 4, Q2: 7, Q3: 10, Q4: 13
    year_start + (quarter_offset - 1).months
  end
end
