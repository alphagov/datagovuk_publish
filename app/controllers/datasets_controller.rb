class DatasetsController < ApplicationController
  before_action :authenticate_user!

  def new
    @dataset = Dataset.new
  end

  def create
    @dataset = Dataset.new(params.require(:dataset).permit(:id, :title, :description))
    @dataset.organisation = current_user.primary_organisation

    if @dataset.save
      redirect_to dataset_license_path(@dataset.id)
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

  DATASET_PERMITTED_PARAMS = [
    :licence,
    :licence_other
  ]

  def save_and_update
    refer_to = params.require(:dataset).permit(:flow, :action)
    dataset_params = params.require(:dataset).permit(*DATASET_PERMITTED_PARAMS)
    dataset_params[:licence] = get_licence(dataset_params)

    current_dataset.update_attributes(dataset_params)
    current_dataset.save!

    if refer_to[:flow] = 'new'
      redirect_to action: refer_to[:action]
    else
      redirect_to edit_dataset_path(current_dataset)
    end
  end

  private
  def get_licence(dataset_params)
    if dataset_params[:licence] == 'other'
      return dataset_params[:licence_other]
    end

    'uk-ogl'
  end

  def current_dataset
    Dataset.find(params.require(:dataset_id))
  end
end
