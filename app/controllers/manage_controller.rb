class ManageController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_user!

  def manage_own
    @organisation = current_user.primary_organisation
    @datasets = Dataset.where(organisation: @organisation.id, creator_id: current_user.id)
    @find_url = ""
    @sort = "published"
  end

  def manage_organisation
    @organisation = current_user.primary_organisation
    @datasets = Dataset.where(organisation: @organisation.id)
    @find_url = ""
    @sort = "published"
  end

end

