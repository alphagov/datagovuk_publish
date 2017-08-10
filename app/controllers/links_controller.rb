class LinksController < ApplicationController
  before_action :set_current_dataset
  skip_before_action :set_current_dataset, only: [:preview]

  def new
    @link = Link.new
  end

  def edit
    @link = current_link
  end

  def create
    file_params = params.require(:link).permit(:url, :name,
                                               :start_day, :start_month, :start_year,
                                               :end_day, :end_month, :end_year,
                                               :year, :quarter)
    @link = Link.new(file_params)
    @link.dataset = @dataset

    if @link.save
      redirect_to links_path(@dataset)
    else
      render 'new'
    end
  end

  def update
    @link = current_link
    file_params = params.require(:link).permit(:url, :name,
                                               :start_day, :start_month, :start_year,
                                               :end_day, :end_month, :end_year,
                                               :year, :quarter)
    @link.update_attributes(file_params)

    if @link.save
      redirect_to links_path(@dataset)
    else
      render 'edit'
    end
  end

  def confirm_delete
    @link = current_link
    flash[:alert] = "Are you sure you want to delete ‘#{@link.name}’?"

    redirect_to links_path(file_id: @link.id)
  end

  def destroy
    @link = current_link
    flash[:deleted] = "Your link ‘#{@link.name}’ has been deleted"
    @link.destroy

    redirect_to links_path(@dataset)
  end

  def index
    @links = @dataset.links
  end

  def preview
    link = Link.find(params.require(:file_id))
    render json: link.preview || {}
  end


  private
  def set_current_dataset
    @dataset = current_dataset
  end

  def current_dataset
    Dataset.find_by(:name => params.require(:id)) || Dataset.find(params.require(:id))
  end

  def current_link
    Link.find(params.require(:file_id))
  end
end
