# coding: utf-8
class Datasets::LinksController < ApplicationController
  before_action :set_dataset, only: [:index, :new, :create, :edit, :update, :confirm_delete, :destroy]
  before_action :set_link,    only: [:edit, :update, :confirm_delete, :destroy]

  def index
    @links = @dataset.links
  end

  def new
    @link = @dataset.links.build
  end

  def create
    @link = @dataset.links.build(link_params.slice(:url, :name).merge(date_fields: date_params))

    if @link.save
      redirect_to dataset_links_path(@dataset.uuid, @dataset.name)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @link = @dataset.links.build(link_params.slice(:url, :name).merge(date_fields: date_params))

    if @link.save
      redirect_to dataset_links_path(@dataset.uuid, @dataset.name)
    else
      render :edit
    end
  end

  def confirm_delete
    flash[:alert] = "Are you sure you want to delete ‘#{@link.name}’?"
    flash[:link_id] = @link.id

    redirect_to dataset_links_path(@dataset.uuid, @dataset.name)
  end

  def destroy
    flash[:deleted] = "Your link ‘#{@link.name}’ has been deleted"
    @link.destroy

    redirect_to dataset_links_path(@dataset.uuid, @dataset.name)
  end

  private

  def set_dataset
    @dataset = Dataset.find_by(uuid: params[:uuid])
  end

  def set_link
    @link = Link.find(params[:id])
  end

  def link_params
    params.require(:link).permit(
      :url,
      :name,
      :start_day, :start_month, :start_year,
      :end_day, :end_month, :end_year,
      :year,
      :quarter
    )
  end

  def date_params
    {
      days: {
        start: link_params[:start_day],
        end: link_params[:end_day]
      },
      months: {
        start: link_params[:start_month],
        end: link_params[:end_month]
      },
      years: {
        start: link_params[:start_year],
        end: link_params[:end_year]
      }
    }
  end
end
