require 'uri'

class Datafile < ApplicationRecord
  belongs_to :dataset

  validates :url, presence: true
  validates :name, presence: true

  scope :published, -> { where(published: true) }
  scope :draft,     -> { where(published: false) }

  scope :datalinks,     -> { where(documentation: [false, nil]) }
  scope :documentation, -> { where(documentation: true) }
end
