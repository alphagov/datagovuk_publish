require 'securerandom'

class Organisation < ApplicationRecord
  audited
  has_many :datasets, dependent: :destroy
  before_save :set_uuid

private

  def set_uuid
    self.uuid = SecureRandom.uuid if self.uuid.blank?
  end
end
