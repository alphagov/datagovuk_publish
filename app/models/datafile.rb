class Datafile < ApplicationRecord
  belongs_to :dataset
  before_save :set_dates

  validates :url, presence: { message: 'Please enter a valid URL' }
  validates :name, presence: { message: 'Please enter a valid name' }
end
