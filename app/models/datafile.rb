class Datafile < ApplicationRecord
  belongs_to :dataset

  scope :published, -> { where(published: true) }
  scope :draft,     -> { where(published: false) }

  scope :datalinks,     -> { where(documentation: false) }
  scope :documentation, -> { where(documentation: true) }
end
