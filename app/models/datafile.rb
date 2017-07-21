require 'validators/url_validator'

class Datafile < ApplicationRecord
  belongs_to :dataset

  # validates :url, presence: true
  validates :name, presence: true
  validates_with UrlValidator
end
