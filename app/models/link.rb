require 'validators/date_validator'

class Link < Datafile
  attr_accessor :start_day, :start_month, :start_year,
                :end_day,   :end_month,   :end_year

  validates :quarter, presence: true,
    if: -> { !self.documentation && self.dataset.quarterly? }
  validates_with DateValidator

  def dates
    {
      start: {
        day: start_date&.day,
        month: start_date&.month,
        year: start_date&.year
      },
      end: {
        day: end_date&.day,
        month: end_date&.month,
        year: end_date&.year
      }
    }.with_indifferent_access
  end
end
