class Datafile < ApplicationRecord
  belongs_to :dataset

  validates :url, presence: true
  validates :name, presence: true
end
