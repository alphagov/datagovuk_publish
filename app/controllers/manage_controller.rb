class ManageController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_user!
  include ManageHelper

  def manage_own
    set_common_args
    @datasets = get_query(true)
    manage_sort
  end

  def manage_organisation
    set_common_args
    @datasets = get_query(false)
    manage_sort
  end

  def get_query(with_owned)
    has_search_term = params[:q] != "" && params[:q] != nil

    args = {
      organisation: @organisation.id,
    }

    if with_owned
      args[:creator_id] = current_user.id
    end

    perform_query(args, has_search_term).page params[:page]
  end

  def perform_query(args, has_terms)
    if has_terms
      args[:search] = params[:q].downcase
      query_string = "name ILIKE CONCAT('%',:search,'%') OR title ILIKE CONCAT('%',:search,'%')"
      Dataset.where(query_string, args)
    else
      Dataset.where(args)
    end
  end

  def set_common_args
    @organisation = current_user.primary_organisation
    @find_url = ""
    @q = params[:q]
  end

  private :set_common_args, :get_query, :perform_query
end
