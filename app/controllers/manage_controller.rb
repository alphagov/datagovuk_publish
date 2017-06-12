class ManageController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_user!

  def manage_own
    set_common_args
    @datasets = get_query(true)
  end

  def manage_organisation
    set_common_args
    @datasets = get_query(false)
  end


  def get_query(with_owned)
    has_search_term = params[:q] != "" && params[:q] != nil

    args = {
      organisation: @organisation.id,
    }

    if with_owned
      args[:creator_id] = current_user.id
    end

    result = if has_search_term
               args[:search] = params[:q].downcase
               query_string = "name ILIKE CONCAT('%',:search,'%') OR title ILIKE CONCAT('%',:search,'%')"
               Dataset.where(query_string, args)
             else
               Dataset.where(args)
             end

    result.page params[:page]

  end

  def set_common_args
    @organisation = current_user.primary_organisation
    @find_url = ""
    @sort = "published"
    @q = params[:q]
  end

  private :set_common_args, :get_query
end
