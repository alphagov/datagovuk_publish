class Topic < ApplicationRecord
  has_many :datasets, dependent: :restrict_with_exception
end
