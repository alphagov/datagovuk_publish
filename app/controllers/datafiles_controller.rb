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
    file_params = params.require(:datafile).permit(:url, :name,
                                                   :start_day, :start_month, :start_year,
                                                   :end_day, :end_month, :end_year,
                                                   :year, :quarter)
    @datafile = Datafile.new(file_params)
    @datafile.dataset = @dataset

    if documents?
      @datafile.documentation = true
    else
      set_dates(params.require(:datafile).permit(DATE_PARAMS))
    end

    if @datafile.save
      redirect_to files_path(@dataset, new: true) if files?
      redirect_to documents_path(@dataset) if documents?
    else
      redirect_to action: :new, flash: @datafile.errors
    end
  end

  def update
    @datafile = current_datafile
    file_params = params.require(:datafile).permit(:url, :name,
                                                   :start_day, :start_month, :start_year,
                                                   :end_day, :end_month, :end_year,
                                                   :year, :quarter)
    @datafile.update_attributes(file_params)

    if @datafile.save
      redirect_to files_path(@dataset) if files?
      redirect_to documents_path(@dataset) if documents?
    else
      redirect_to action: :edit, flash: @datafile.errors
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
