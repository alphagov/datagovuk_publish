class DatasetsController < ApplicationController
  before_action :authenticate_user!

  def new
    @dataset = Dataset.new
  end

  def create
    @dataset = Dataset.new(dataset_params)
    @dataset.organisation = current_user.primary_organisation

    if @dataset.save
      redirect_to dataset_license_path(@dataset.id)
    else
      render 'new'
    end
  end

  def license
    @dataset = current_dataset
  end

  def save_and_update
    # Handle

    redirect_to
  end

  private
  def current_dataset
    Dataset.find(dataset_params[:dataset_id])
  end

  def dataset_params
    params.permit(:dataset_id, :dataset, :id, :title, :summary, :description)
  end
end
