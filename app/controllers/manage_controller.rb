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
    search_term = params[:q] != "" && params[:q] != nil

    args = {}

    if with_owned
      args[:creator_id] = current_user.id
    end

    perform_query(args, search_term).page params[:page]
  end

  def perform_query(args, terms)
    if terms
      args[:search] = params[:q].downcase
      q_org = "name ILIKE CONCAT('%',:search,'%') OR title ILIKE CONCAT('%',:search,'%')"
      q_own = "AND creator_id =(:creator_id)"
      args[:creator_id] ? @organisation.datasets.where(q_org + q_own, args) : @organisation.datasets.where(q_org, args)
    else
      @organisation.datasets.where(args)
    end
  end

  def set_common_args
    @organisation = current_user.primary_organisation
    @find_url = ENV["FIND_URL"] || ""
    @q = params[:q]
  end

  private :set_common_args, :get_query, :perform_query
end
