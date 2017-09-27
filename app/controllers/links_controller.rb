class LinksController < ApplicationController
  before_action :set_dataset
  skip_before_action :set_dataset, only: [:preview]

  before_action :set_link, only: [:edit, :update, :destroy]

  def index
    @links = @dataset.links
  end

  def new
    @link = Link.new
  end

  def edit
  end

  def create
    @link = @dataset.links.build(link_params)

    if @link.save
      redirect_to links_path(@dataset)
    else
      render :new
    end
  end

  def update
    if @link.update(link_params)
      redirect_to links_path(@dataset)
    else
      render :edit
    end
  end

  def confirm_delete
    @link = Link.find(params[:file_id])
    flash[:alert] = "Are you sure you want to delete ‘#{@link.name}’?"

    redirect_to links_path(file_id: @link.id)
  end

  def destroy
    flash[:deleted] = "Your link ‘#{@link.name}’ has been deleted"
    @link.destroy

    redirect_to links_path(@dataset)
  end

  def preview
    link = Link.find(params[:file_id])
    dataset = link.dataset

    preview_content = (link.preview.as_json || {})
    preview_content[:meta] = {
      dataset_id: dataset.id,
      dataset_title: dataset.title,
      dataset_name: dataset.name,
      datafile_id: link.id,
      datafile_name: link.name,
      datafile_link: link.url
    }

    render json: preview_content
  end

  private

  def set_dataset
    @dataset = Dataset.find_by(:name => params.require(:id)) || Dataset.find(params.require(:id))
  end

  def set_link
    @link = Link.find(params[:file_id])
  end

  def link_params
    params.require(:link).permit(
      :url,
      :name,
      :start_day, :start_month, :start_year,
      :end_day, :end_month, :end_year,
      :year, :quarter
    )
  end
end
