class DatasetsController < ApplicationController
  before_action :authenticate_user!

  def new
    @dataset = Dataset.new
  end

  def create
    @dataset = Dataset.new(params.require(:dataset).permit(:id, :title, :summary, :description))
    @dataset.organisation = current_user.primary_organisation

    if @dataset.save
      redirect_to new_licence_dataset_path(@dataset.id)
    else
      render 'new'
    end
  end

  def licence
    @dataset = current_dataset
  end

  def location
    @dataset = current_dataset
  end

  def frequency
    @dataset = current_dataset
  end

  def addfile
    @dataset = current_dataset
  end

  def adddoc
    @dataset = current_dataset
  end

  def publish
    @dataset = current_dataset
  end

  DATASET_PERMITTED_PARAMS = [
    :licence,
    :licence_other
  ]

  private
  def get_licence(dataset_params)
    if dataset_params[:licence] == 'other'
      return dataset_params[:licence_other]
    end

    'uk-ogl'
  end

  def current_dataset
    Dataset.find(params.require(:id))
  end
end
