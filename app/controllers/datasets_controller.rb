class DatasetsController < ApplicationController
  before_action :authenticate_user!

  def new
    @dataset = Dataset.new
  end

  def create
    @dataset = Dataset.new(params.require(:dataset).permit(:id, :title, :summary, :description))
    @dataset.organisation = current_user.primary_organisation

    if @dataset.save
      redirect_to new_licence_dataset_path(@dataset)
    else
      render 'new'
    end
  end

  def licence
    @dataset = current_dataset

    if request.put?
      licence = get_licence(params.require(:dataset).permit(:licence, :licence_other))
      @dataset.licence = licence

      redirect_to new_location_dataset_path(@dataset) if @dataset.save
    end
  end

  def location
    @dataset = current_dataset

    if request.put?
      location = params.require(:dataset).permit(:location)[:location]
      @dataset.location1 = location

      redirect_to new_frequency_dataset_path(@dataset) if @dataset.save
    end
  end

  def frequency
    @dataset = current_dataset

    if request.put?
      @dataset.frequency = params.require(:dataset).permit(:frequency)[:frequency]

      redirect_to new_addfile_dataset_path(@dataset) if @dataset.save
    end
  end

  def addfile
    @dataset = current_dataset

    if request.put?
      file_params = params.require(:dataset).permit(:url, :name)
      datafile = Datafile.new(file_params)

      redirect_to new_adddoc_dataset_path(@dataset) if datafile.save
    end
  end

  def adddoc
    @dataset = current_dataset

    if request.put?
      doc_params = params.require(:dataset).permit(:url, :name)
      doc = Datafile.new(doc_params.merge({documentation: true}))

      redirect_to publish_dataset_path(@dataset) if doc.save
    end
  end

  def publish
    @dataset = current_dataset

    if request.put?
      @dataset.published = true

      redirect_to manage_path if @dataset.save
    end
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
