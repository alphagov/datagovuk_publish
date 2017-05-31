class PublishingUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.primary_organisation
    organisations.order_by('name').first
  end

  def self.__repr__
    email
  end

end
