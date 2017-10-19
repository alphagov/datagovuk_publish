class Datasets::FrequenciesController < ApplicationController
  before_action :authenticate_user!

  def new
    @dataset = current_dataset
  end

  def edit
    @dataset = current_dataset
  end

  def create
    @dataset = current_dataset

    begin
      @dataset.frequency = params.require(:dataset).permit(:frequency)[:frequency]
    rescue ActionController::ParameterMissing
      @dataset.errors.add(:frequency, 'Please indicate how often this dataset is updated')
      render :new
      return
    end

    if @dataset.save
      redirect_to new_dataset_link_path(@dataset)
    else
      render :new
    end
  end

  def update
    @dataset = current_dataset
    @dataset.frequency = params.require(:dataset).permit(:frequency)[:frequency]

    if @dataset.save
      redirect_to dataset_path(@dataset)
    else
      render :edit
    end
  end

  private

  def current_dataset
    Dataset.find_by(name: params[:dataset_id])
  end
end
