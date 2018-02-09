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

  def in_organisation?(organisation)
    user_organisations.include?(organisation)
  end

  def creator_of_dataset?(dataset)
    id == dataset.creator_id
  end

private

  def user_organisations
    organisations + [primary_organisation]
  end
end
