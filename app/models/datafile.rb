class Datafile < ApplicationRecord
  belongs_to :dataset

  validates_presence_of :url
  validates_presence_of :name
end
