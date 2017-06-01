class PublishingUser < ApplicationRecord
  has_and_belongs_to_many :organisations
  belongs_to :primary_organisation, class_name: 'Organisation', foreign_key: 'primary_organisation_id'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
