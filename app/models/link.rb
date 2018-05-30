require 'securerandom'

class Link < ApplicationRecord
  belongs_to :dataset

  validates :name, presence: true

  before_save :set_uuid

  scope :broken, -> { where(broken: true) }

  def set_uuid
    if self.uuid.blank?
      self.uuid = SecureRandom.uuid
    end
  end
end
