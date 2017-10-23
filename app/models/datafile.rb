require 'securerandom'
require 'validators/url_validator'

class Datafile < ApplicationRecord
  belongs_to :dataset

  validates :name, presence: true
  validates_with UrlValidator

  before_save :set_uuid
  after_update :update_legacy

  def set_uuid
    if self.uuid.blank?
      self.uuid = SecureRandom.uuid
    end
  end

  private

  def update_legacy
    PublishToLegacyUpdateDatafilesWorker.perform_async(self.id)
  end

end
