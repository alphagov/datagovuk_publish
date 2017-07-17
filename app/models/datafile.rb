class Datafile < ApplicationRecord
  belongs_to :dataset

  validates :url, presence: { message: 'Please enter a valid URL' }
  validates :name, presence: { message: 'Please enter a valid name' }
end
