class Datasets::LocationsController < ApplicationController
  def new
    @dataset = current_dataset
  end

  def edit
    @dataset = current_dataset
  end

  def create
    @dataset = current_dataset
    location_params = params.require(:dataset).permit(:location1, :location2, :location3)
    @dataset.update!(location_params)

    if @dataset.save
      redirect_to new_dataset_frequency_path(@dataset.uuid, @dataset.name)
    else
      render :new
    end
  end

  def update
    @dataset = current_dataset
    location_params = params.require(:dataset).permit(:location1, :location2, :location3)
    @dataset.update!(location_params)

    if @dataset.save
      redirect_to dataset_path(@dataset.uuid, @dataset.name)
    else
      render :edit
    end
  end

private

  def current_dataset
    Dataset.find_by(uuid: params[:uuid])
  end
end
