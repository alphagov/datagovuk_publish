class User < ApplicationRecord
  include GDS::SSO::User

  has_and_belongs_to_many :organisations
  audited

  def primary_organisation
    organisations.any? ? organisations.first : Organisation.first
  end

  def primary_organisation=(organisation)
    self.organisations = [organisation].compact
  end

  def in_organisation?(organisation)
    organisations.include?(organisation)
  end

  def creator_of_dataset?(dataset)
    id == dataset.creator_id
  end
end
