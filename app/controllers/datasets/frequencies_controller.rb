class Datasets::FrequenciesController < ApplicationController
  def new
    @dataset = current_dataset
  end

  def edit
    @dataset = current_dataset
  end

  def create
    @dataset = current_dataset
    @dataset.frequency = frequency_params[:frequency]

    if @dataset.save(context: :dataset_frequency_form)
      redirect_to new_dataset_datafile_path(@dataset.uuid, @dataset.name)
    else
      render :new
    end
  end

  def update
    @dataset = current_dataset
    @dataset.frequency = params.require(:dataset).permit(:frequency)[:frequency]

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

  def frequency_params
    params.fetch(:dataset, {}).permit(:frequency)
  end
end
