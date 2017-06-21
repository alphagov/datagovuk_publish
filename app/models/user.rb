class User < ApplicationRecord
  has_and_belongs_to_many :organisations
  belongs_to :primary_organisation, class_name: 'Organisation',
    foreign_key: 'primary_organisation_id', optional: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable

  validates :email, presence: true

  audited

  def in_organisation(organisation)
    self.primary_organisation == organisation ||
      self.organisations.include?(organisation)
  end
end
