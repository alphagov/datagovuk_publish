class DatafilesController < ApplicationController
  before_action :set_current_dataset

  def new
    @datafile = Datafile.new

    if documents?
      render 'new_doc'
    end
  end

  def edit
    @datafile = current_datafile

    if documents?
      render 'edit_doc'
    end
  end

  def create
    file_params = params.require(:datafile).permit(:url, :name)
    @datafile = Datafile.new(file_params)
    @datafile.dataset = @dataset
    set_dates(params.require(:datafile).permit(DATE_PARAMS))

    if documents?
      @datafile.documentation = true
    end

    if @datafile.save
      redirect_to files_path(@dataset, new: true) if files?
      redirect_to documents_path(@dataset) if documents?
    end
  end

  def update
    @datafile = current_datafile
    file_params = params.require(:datafile).permit(:url, :name)
    @datafile.update_attributes(file_params)
    set_dates(params.require(:datafile).permit(DATE_PARAMS))

    if @datafile.save
      redirect_to files_path(@dataset) if files?
      redirect_to documents_path(@dataset) if documents?
    end
  end

  def destroy
    @datafile = current_datafile
    @datafile.destroy

    redirect_to files_path(@dataset) if files?
    redirect_to documents_path(@dataset) if documents?
  end

  def index
    @new = new?

    if documents?
      documents
    else
      files
    end
  end

  def files
    @datafiles = @dataset.datafiles.datalinks
    @initialising = params[:new]
    render 'files'
  end

  def documents
    @datafiles = @dataset.datafiles.documentation
    render 'documents'
  end

  private
  def set_current_dataset
    @dataset = current_dataset
  end

  def current_dataset
    Dataset.find_by(:name => params.require(:id)) || Dataset.find(params.require(:id))
  end

  def current_datafile
    Datafile.find(params.require(:file_id))
  end

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

  # TODO: MOVE THESE TO THE CONTROLLER
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

  def files?
    url_contains('/file')
  end

  def documents?
    url_contains('/document')
  end

  def url_contains(action)
    url = request.path
    url.gsub(@dataset.title, '') if @dataset.title
    url.include?(action)
  end

  def new?
    params[:new] == true
  end
end
