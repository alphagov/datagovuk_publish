class User < ApplicationRecord
  include GDS::SSO::User

  def primary_organisation
    @@org || Organisation.first
  end

  def primary_organisation=(org)
    @@org = org
  end
end
