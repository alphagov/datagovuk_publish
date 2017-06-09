class Dataset < ApplicationRecord
  belongs_to :organisation

  validates :title, presence: true
  validates :summary, presence: true
end
