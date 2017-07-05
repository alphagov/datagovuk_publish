class Organisation < ApplicationRecord
  extend FriendlyId

  audited
  has_and_belongs_to_many :users
  has_many :tasks, dependent: :destroy
  has_many :datasets
  friendly_id :slug_candidates, :use => :slugged, :slug_column => :name

  before_destroy :deregister_users

  def active?
    active
  end

  def closed?
    !active?
  end

  private
  def deregister_users
    users.where(primary_organisation: self).each do |p|
      p.primary_organisation = nil
      p.save!
    end
  end

  def slug_candidates
    [:title, :title_and_sequence]
  end

  def title_and_sequence
    slug = title.to_param
    sequence = Organisation.where("name like ?", "#{slug}-%").count + 2
    "#{slug}-#{sequence}"
  end

end
