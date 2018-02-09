class ManageController < ApplicationController
  protect_from_forgery prepend: true
  before_action :authenticate_user!

  helper_method :sort_column, :sort_direction

  def manage_own
    @organisation = current_user.primary_organisation
    @datasets = @organisation.datasets.owned_by(current_user.id)
    @q = params[:q]

    if @q.present?
      @datasets = @datasets.where(sql_query, query: @q.downcase)
    end

    @datasets = @datasets.order("#{sort_column} #{sort_direction}").page(params[:page]).per(params[:per])
  end

  def manage_organisation
    @organisation = current_user.primary_organisation
    @datasets = @organisation.datasets
    @q = params[:q]

    if @q.present?
      @datasets = @datasets.where(sql_query, query: @q.downcase)
    end

    @datasets = @datasets.order("#{sort_column} #{sort_direction}").page(params[:page]).per(params[:per])
  end

  private

  def sql_query
    "name ILIKE CONCAT('%',:query,'%') OR title ILIKE CONCAT('%',:query,'%')"
  end

  def sort_column
    # check params[:sort] value is valid before passing it to SQL
    # to prevent SQL injection attacks
    Dataset.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    # check params[:direction] value is valid before passing it to SQL
    # to prevent SQL injection attacks
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
