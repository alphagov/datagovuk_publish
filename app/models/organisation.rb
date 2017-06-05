class Organisation < ApplicationRecord
  has_and_belongs_to_many :publishing_users
end
