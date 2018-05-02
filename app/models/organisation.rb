require 'securerandom'

class Organisation < ApplicationRecord
  extend FriendlyId
  has_ancestry

  audited
  has_many :tasks, dependent: :destroy
  has_many :datasets
  friendly_id :slug_candidates, use: :slugged, slug_column: :name
  before_save :set_uuid

private

  def set_uuid
    self.uuid = SecureRandom.uuid if self.uuid.blank?
  end

  def slug_candidates
    %i[title title_and_sequence]
  end

  def title_and_sequence
    slug = title.to_param
    sequence = Organisation.where("name like ?", "#{slug}-%").count + 2
    "#{slug}-#{sequence}"
  end
end
