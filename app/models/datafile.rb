require 'uri'

class Datafile < ApplicationRecord
  belongs_to :dataset

  validates :url, presence: true
  validates :name, presence: true

  scope :published, -> { where(published: true) }
  scope :draft,     -> { where(published: false) }

  scope :datalinks,     -> { where(documentation: [false, nil]) }
  scope :documentation, -> { where(documentation: true) }

  def quarter
    if start_date
      year_quarter = (start_date.month - 1) / 3

      if year_quarter == 0
        4
      else
        year_quarter
      end
    else
      nil
    end
  end

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

  def start_day
    start_date.try(:day)
  end

  def start_month
    start_date.try(:month)
  end

  def start_year
    start_date.try(:year)
  end

  def end_day
    end_date.try(:day)
  end

  def end_month
    end_date.try(:month)
  end

  def end_year
    end_date.try(:year)
  end
end
