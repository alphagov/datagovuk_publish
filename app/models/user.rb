class User < ApplicationRecord
  include GDS::SSO::User
  audited

  def primary_organisation
    return unless organisation_content_id

    Organisation.find_by(govuk_content_id: organisation_content_id)
  end

  def primary_organisation=(organisation)
    update(organisation_content_id: organisation.govuk_content_id)
  end

  def in_organisation?(organisation)
    organisation.govuk_content_id == organisation_content_id
  end

  def creator_of_dataset?(dataset)
    id == dataset.creator_id
  end
end
