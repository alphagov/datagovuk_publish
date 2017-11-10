require 'securerandom'
require 'validators/url_validator'

class Datafile < ApplicationRecord
  belongs_to :dataset

  validates :name, presence: true
  validates_with UrlValidator

  scope :created_before_date, ->(date) { where('created_at < ?', date) }
  scope :created_after_date,  ->(date) { where('created_at > ?', date) }
  scope :updated_after_date,  ->(date) { where('updated_at > ?', date) }

  before_save :set_uuid

  def set_uuid
    if self.uuid.blank?
      self.uuid = SecureRandom.uuid
    end
  end

end
