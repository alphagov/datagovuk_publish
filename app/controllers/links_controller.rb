# coding: utf-8
class LinksController < ApplicationController
  before_action :set_dataset, only: [:index, :new, :create, :edit, :update, :confirm_delete, :destroy]
  before_action :set_link,    only: [:edit, :update, :confirm_delete, :destroy]

  def index
    @links = @dataset.links
  end

  def new
    @link = @dataset.links.build
  end

  def create
    @link = @dataset.links.build(link_params)

    if @link.save
      redirect_to dataset_links_path(@dataset)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @link.update(link_params)
      redirect_to dataset_links_path(@dataset)
    else
      render :edit
    end
  end

  def confirm_delete
    flash[:alert] = "Are you sure you want to delete ‘#{@link.name}’?"
    flash[:link_id] = @link.id

    redirect_to dataset_links_path(@dataset)
  end

  def destroy
    flash[:deleted] = "Your link ‘#{@link.name}’ has been deleted"
    @link.destroy

    redirect_to dataset_links_path(@dataset)
  end

  private

  def set_dataset
    @dataset = Dataset.find_by(name: params[:dataset_id]) || Dataset.find(params[:dataset_id])
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
end
