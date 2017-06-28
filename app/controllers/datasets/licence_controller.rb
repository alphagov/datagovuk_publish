class Datasets::LicenceController < ApplicationController
  before_action :authenticate_user!

  def new
    @dataset = current_dataset
  end

  def edit
    @dataset = current_dataset
  end

  def create
    @dataset = current_dataset
    licence = get_licence(params.require(:dataset).permit(:licence, :licence_other))
    @dataset.licence = licence

    if @dataset.save
      redirect_to new_location_dataset_path(@dataset)
    else
      render 'new'
    end
  end

  def update
    @dataset = current_dataset
    licence = get_licence(params.require(:dataset).permit(:licence, :licence_other))
    @dataset.licence = licence

    if @dataset.save
      redirect_to dataset_path(@dataset)
    else
      render 'edit'
    end
  end

  private
  def current_dataset
    Dataset.find_by(:name => params.require(:id))
  end

  def get_licence(dataset_params)
    if dataset_params[:licence] == 'other'
      return dataset_params[:licence_other]
    end

    'uk-ogl'
  end
end
