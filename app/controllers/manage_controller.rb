class ManageController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_user!
  include ManageHelper

  def manage_own
    set_common_args
    @datasets = get_query
    manage_sort
  end

  def manage_organisation
    set_common_args
    @datasets = get_query
    manage_sort
  end

  def get_query
    search_term = params[:q] != "" && params[:q] != nil
    perform_query(search_term).page params[:page]
  end

  def perform_query(search_term)
    if search_term
      args = {search: params[:q].downcase}
      query_string = "name ILIKE CONCAT('%',:search,'%') OR title ILIKE CONCAT('%',:search,'%')"
      @organisation.datasets.where(query_string, args)
    else
      @organisation.datasets
    end
  end

  def set_common_args
    @organisation = current_user.primary_organisation
    @find_url = ""
    @q = params[:q]
  end

  private :set_common_args, :get_query, :perform_query
end
