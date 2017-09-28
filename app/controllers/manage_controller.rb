class ManageController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_user!
  include ManageHelper

  def manage_own
    @organisation = current_user.primary_organisation
    @datasets = @organisation.datasets.owned_by(current_user.id)
    @q = params[:q]

    if @q.present?
      @datasets = @datasets.where(sql_query, query: @q.downcase).page(params[:page])
    else
      @datasets.page(params[:page])
    end

    manage_sort
  end

  def manage_organisation
    @organisation = current_user.primary_organisation
    @datasets = @organisation.datasets
    @q = params[:q]

    if @q.present?
      @datasets = @datasets.where(sql_query, query: @q.downcase).page(params[:page])
    else
      @datasets.page(params[:page])
    end

    manage_sort
  end

  private

  def sql_query
    "name ILIKE CONCAT('%',:query,'%') OR title ILIKE CONCAT('%',:query,'%')"
  end
end
