require 'securerandom'
require 'validators/url_validator'

class Link < ApplicationRecord

  belongs_to :dataset

  validates :name, presence: true
  validates_with UrlValidator

  before_save :set_uuid
  after_initialize :set_short_id
  
  scope :broken, ->{ where(broken: true) }

  def set_uuid
    if self.uuid.blank?
      self.uuid = SecureRandom.uuid
    end
  end

  def set_short_id
    if self.short_id.blank?
      candidate_short_id = generate_short_id 

      while Link.where(short_id: candidate_short_id).exists? do
        candidate_short_id = generate_short_id
      end

      self.short_id = candidate_short_id
    end
  end

  def generate_short_id
    SecureRandom.urlsafe_base64(6, true)
  end
end
