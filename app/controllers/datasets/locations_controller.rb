class Datasets::LocationsController < ApplicationController
  include UpdateLegacy
  before_action :authenticate_user!

  def new
    @dataset = current_dataset
  end

  def edit
    @dataset = current_dataset
  end

  def create
    @dataset = current_dataset
    location_params = params.require(:dataset).permit(:location1, :location2, :location3)
    @dataset.update_attributes(location_params)

    if @dataset.save
      redirect_to new_frequency_path(@dataset)
    else
      render "new"
    end
  end

  def update
    @dataset = current_dataset
    location_params = params.require(:dataset).permit(:location1, :location2, :location3)
    @dataset.update_attributes(location_params)

    if @dataset.save
      update_legacy
      redirect_to dataset_path(@dataset)
    else
      render 'edit'
    end
  end

  private
  def current_dataset
    Dataset.find_by(:name => params.require(:id))
  end
end
