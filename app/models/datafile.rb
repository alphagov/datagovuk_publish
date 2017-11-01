require 'securerandom'
require 'validators/url_validator'

class Datafile < ApplicationRecord
  belongs_to :dataset

  validates :name, presence: true
  validates_with UrlValidator

  scope :updated_after, ->(date) {where('updated_at > ?', date)}

  before_save :set_uuid

  def set_uuid
    if self.uuid.blank?
      self.uuid = SecureRandom.uuid
    end
  end

  def update_legacy
    Legacy::Datafile.new(self).update
  end
end
