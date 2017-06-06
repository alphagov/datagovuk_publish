class Organisation < ApplicationRecord
  has_and_belongs_to_many :publishing_users
  audited

  def active?
    active
  end

  def closed?
    !active?
  end
end
