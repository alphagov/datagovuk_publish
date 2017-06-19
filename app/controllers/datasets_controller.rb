class DatasetsController < ApplicationController
  before_action :authenticate_user!

  def new
    @dataset = Dataset.new
  end

  def create
    @dataset = Dataset.new(params.require(:dataset).permit(:id, :title, :summary, :description))
    @dataset.creator_id = current_user.id
    @dataset.organisation = current_user.primary_organisation

    if @dataset.save
      redirect_to new_licence_dataset_path(@dataset)
    else
      render 'new'
    end
  end

  def licence
    @dataset = current_dataset

    if request.post?
      licence = get_licence(params.require(:dataset).permit(:licence, :licence_other))
      @dataset.licence = licence

      redirect_to new_location_dataset_path(@dataset) if @dataset.save
    end
  end

  def location
    @dataset = current_dataset

    if request.post?
      location_params = params.require(:dataset).permit(:location1, :location2, :location3)
      @dataset.update_attributes(location_params)

      redirect_to new_frequency_dataset_path(@dataset) if @dataset.save
    end
  end

  def frequency
    @dataset = current_dataset

    if request.post?
      @dataset.frequency = params.require(:dataset).permit(:frequency)[:frequency]

      redirect_to new_addfile_dataset_path(@dataset) if @dataset.save
    end
  end

  def addfile
    @dataset = current_dataset
    @datafile = Datafile.new

    if request.post?
      file_params = params.require(:datafile).permit(:url, :name)
      @datafile = Datafile.new(file_params)
      @datafile.dataset = @dataset
      set_dates(params.require(:datafile).permit(DATE_PARAMS))

      if @datafile.save
        redirect_to new_adddoc_dataset_path(@dataset)
      end
    end
  end

  def adddoc
    @dataset = current_dataset
    @doc = Datafile.new

    if request.post?
      doc_params = params.require(:datafile).permit(:url, :name)
      @doc = Datafile.new(doc_params)
      @doc.documentation = true
      @doc.dataset = @dataset

      redirect_to publish_dataset_path(@dataset) if @doc.save
    end
  end

  def publish
    @dataset = current_dataset

    if request.post?
      @dataset.published = true

      redirect_to manage_path if @dataset.save
    end
  end

  DATASET_PERMITTED_PARAMS = [
    :licence,
    :licence_other
  ]

  private
  DATE_PARAMS = [
    :quarter,
    :year,
    :start_day,
    :start_month,
    :start_year,
    :end_day,
    :end_month,
    :end_year
  ]

  # TODO NEEDS TESTS!
  def set_dates(date_params)
    if @dataset.weekly? || @dataset.monthly?
      @datafile.start_date = start_date(date_params)
    end

    if @dataset.weekly?
      @datafile.end_date = end_date(date_params)
    elsif @dataset.monthly?
      @datefile.end_date = @datafile.start_date + 1.month
    end

    if @dataset.quarterly?
      @datafile.start_date = quarter(date_params)
    end

    if @dataset.annually?
      @datafile.start_date = Date.new(date_params[:year])
      @datafile.end_date = Date.new(date_params[:year]) + 1.year
    end

    if @dataset.financial_yearly?
      @datafile.start_date = Date.new(date_params[:year], 4, 1)
      @datafile.end_date = Date.new(date_params[:year], 4, 1) + 1.year
    end
  end

  def start_date(date_params)
    Date.new(date_params[:start_year], date_params[:start_month], date_params[:start_day])
  end

  def end_date(date_params)
    Date.new(date_params[:end_year], date_params[:end_month], date_params[:end_day])
  end

  def quarter(date_params)
    year_start = Date.new(date_params[:year], 1, 1)
    quarter_offset = 4 + (data_params[:quarter] - 1) * 3 # Q1: 4, Q2: 7, Q3: 10, Q4: 13
    year_start + quarter_offset.months
  end

  def get_licence(dataset_params)
    if dataset_params[:licence] == 'other'
      return dataset_params[:licence_other]
    end

    'uk-ogl'
  end

  def current_dataset
    Dataset.find_by(:name => params.require(:id))
  end
end
