class DatasetsController < ApplicationController
  before_action :authenticate_user!

  def show
    @dataset = current_dataset
  end

  def new
    @dataset = Dataset.new
  end

  def edit
    @dataset = current_dataset
  end

  def create
    @dataset = Dataset.new(params.require(:dataset).permit(:id, :title, :summary, :description))
    @dataset.creator_id = current_user.id
    @dataset.organisation = current_user.primary_organisation

    if @dataset.save
      redirect_to new_licence_path(@dataset)
    else
      render 'new'
    end
  end

  def update
    @dataset = current_dataset
    @dataset.update_attributes(params.require(:dataset).permit(:title, :summary, :description))

    if @dataset.save
      redirect_to dataset_path(@dataset)
    else
      render 'edit'
    end
  end

  def files
    @dataset = current_dataset
    @datafiles = @dataset.datafiles.datalinks

    if request.post?
      redirect_to new_document_path(@dataset)
    end
  end

  def documents
    @dataset = current_dataset
    @datafiles = @dataset.datafiles.documentation

    if request.post?
      redirect_to publish_dataset(@dataset)
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
        redirect_to files_path(@dataset) if request.post?
        redirect_to edit_dataset_path(@dataset) if request.put?
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

      redirect_to new_document_path(@dataset) if @doc.save
    end
  end

  def publish
    @dataset = current_dataset

    if request.post?
      @dataset.published = true

      flash[:success] = I18n.t 'dataset_published'
      flash[:extra] = @dataset

      if @dataset.save
        redirect_to manage_path
      else
        render 'show'
      end
    end
  end

  private
  def current_dataset
    Dataset.find_by(:name => params.require(:id))
  end

  def current_file
    Datafile.find(params.require(:file_id))
  end
end
