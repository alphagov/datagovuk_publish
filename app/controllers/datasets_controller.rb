class DatasetsController < ApplicationController
  before_action :authenticate_user!

  def show
    @dataset = current_dataset
  end

  def new
    @dataset = Dataset.new
    render 'dataset'
  end

  def edit
    @dataset = current_dataset
    render 'dataset'
  end

  def create
    @dataset = Dataset.new(params.require(:dataset).permit(:id, :title, :summary, :description))
    @dataset.creator_id = current_user.id
    @dataset.organisation = current_user.primary_organisation

    if @dataset.save
      redirect_to new_licence_dataset_path(@dataset)
    else
      render 'dataset'
    end
  end

  def update
    @dataset = current_dataset
    @dataset.update_attributes(params.require(:dataset).permit(:title, :summary, :description))

    if @dataset.save
      redirect_to dataset_path(@dataset)
    else
      render 'dataset'
    end
  end

  def licence
    @dataset = current_dataset

    unless request.get?
      licence = get_licence(params.require(:dataset).permit(:licence, :licence_other))
      @dataset.licence = licence

      if @dataset.save
        redirect_to new_location_dataset_path(@dataset) if request.post?
        redirect_to dataset_path(@dataset) if request.put?
      end
    end
  end

  def location
    @dataset = current_dataset

    unless request.get?
      location_params = params.require(:dataset).permit(:location1, :location2, :location3)
      @dataset.update_attributes(location_params)

      if @dataset.save
        redirect_to new_frequency_dataset_path(@dataset) if request.post?
        redirect_to dataset_path(@dataset) if request.put?
      end
    end
  end

  def frequency
    @dataset = current_dataset

    unless request.get?
      @dataset.frequency = params.require(:dataset).permit(:frequency)[:frequency]

      if @dataset.save
        redirect_to new_addfile_dataset_path(@dataset) if request.post?
        redirect_to dataset_path(@dataset) if request.put?
      end
    end
  end

  def addfile
    @dataset = current_dataset
    @datafile = Datafile.new

    unless request.get?
      file_params = params.require(:datafile).permit(:url, :name)
      @datafile = Datafile.new(file_params)
      @datafile.dataset = @dataset
      set_dates(params.require(:datafile).permit(DATE_PARAMS))

      if @datafile.save
        redirect_to new_files_dataset_path(@dataset) if request.post?
        redirect_to edit_dataset_path(@dataset) if request.put?
      end
    end
  end

  def files
    @dataset = current_dataset
    @datafiles = @dataset.datafiles.datalinks

    if request.post?
      redirect_to new_adddoc_dataset_path(@dataset)
    end
  end

  def documents
    @dataset = current_dataset
    @datafiles = @dataset.datafiles.documentation

    if request.post?
      redirect_to publish_dataset(@dataset)
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

      redirect_to new_documents_dataset_path(@dataset) if @doc.save
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

  def set_dates(date_params)
    set_weekly_dates(date_params)           if @dataset.weekly?
    set_monthly_dates(date_params)          if @dataset.monthly?
    set_quarterly_dates(date_params)        if @dataset.quarterly?
    set_yearly_dates(date_params)           if @dataset.annually?
    set_financial_yearly_dates(date_params) if @dataset.financial_yearly?
  end

  def set_weekly_dates(date_params)
    @datafile.start_date = start_date(date_params)
    @datafile.end_date = end_date(date_params)
  end

  def set_monthly_dates(date_params)
    @datafile.start_date = start_date(date_params)
    @datafile.end_date = @datafile.start_date.end_of_month
  end

  def set_quarterly_dates(date_params)
    @datafile.start_date = quarter(date_params)
    @datafile.end_date = (@datafile.start_date + 2.months).end_of_month
  end

  def set_yearly_dates(date_params)
    @datafile.start_date = Date.new(date_params[:year].to_i)
    @datafile.end_date = Date.new(date_params[:year].to_i, 12).end_of_month
  end

  def set_financial_yearly_dates(date_params)
    @datafile.start_date = Date.new(date_params[:year].to_i, 4, 1)
    @datafile.end_date = Date.new(date_params[:year].to_i + 1, 3).end_of_month
  end

  def start_date(date_params)
    if @dataset.monthly?
      date_params[:start_day] = "1"
    end

    Date.new(date_params[:start_year].to_i,
             date_params[:start_month].to_i,
             date_params[:start_day].to_i)
  end

  def end_date(date_params)
    Date.new(date_params[:end_year].to_i,
             date_params[:end_month].to_i,
             date_params[:end_day].to_i)
  end

  def quarter(date_params)
    year_start = Date.new(date_params[:year].to_i, 1, 1)
    quarter_offset = 4 + (date_params[:quarter].to_i - 1) * 3 # Q1: 4, Q2: 7, Q3: 10, Q4: 13
    year_start + (quarter_offset - 1).months
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
