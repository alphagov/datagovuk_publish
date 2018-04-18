class User < ApplicationRecord
  include GDS::SSO::User

  def primary_organisation
    Organisation.first
  end
end
