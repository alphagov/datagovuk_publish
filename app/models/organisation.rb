class Organisation < ApplicationRecord
  audited
  has_and_belongs_to_many :publishing_users
  has_many :tasks, dependent: :destroy

  before_destroy :deregister_users

  def active?
    active
  end

  def closed?
    !active?
  end

  private
  def deregister_users
    publishing_users.where(primary_organisation: self).each do |p|
      p.primary_organisation = nil
      p.save!
    end
  end

end
