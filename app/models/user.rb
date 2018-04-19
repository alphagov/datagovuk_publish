class User < ApplicationRecord
  include GDS::SSO::User
  has_and_belongs_to_many :organisations

  def primary_organisation
    organisations.first || Organisation.first
  end

  def primary_organisation=(org)
    organisations << org
  end
end
