require 'securerandom'

class Datafile < ApplicationRecord
  belongs_to :dataset

  validates :url, presence: true
  validates :name, presence: true

  before_save :set_uuid

  def set_uuid
    if self.uuid.blank?
      self.uuid = SecureRandom.uuid
    end
  end

end
