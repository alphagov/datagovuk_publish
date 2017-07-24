class DocsController < ApplicationController
  before_action :set_current_dataset

  def index
    @datafiles = @dataset.docs
  end

  def new
    @doc = Doc.new
  end

  def create
    file_params = params.require(:doc).permit(:url, :name)
    @doc = Doc.new(file_params)
    @doc.dataset = @dataset

    if @doc.save
      redirect_to docs_path(@dataset)
    else
      render 'new'
    end
  end

  def edit
    @doc = current_doc
  end

  def update
    @doc = current_doc
    doc_params = params.require(:doc).permit(:url, :name)
    @doc.update_attributes(doc_params)

    if @doc.save
      redirect_to docs_path(@dataset)
    else
      render 'edit'
    end
  end

  def confirm_delete
    @doc = current_doc
    flash[:alert] = "Are you sure you want to delete ‘#{@doc.name}’?"

    redirect_to docs_path(file_id: @doc.id)
  end

  def destroy
    @doc = current_doc
    flash[:deleted] = "Your link ‘#{@doc.name}’ has been deleted"
    @doc.destroy

    redirect_to docs_path(@dataset)
  end

  private
  def set_current_dataset
    @dataset = current_dataset
  end

  def current_dataset
    Dataset.find_by(name: params.require(:id)) || Dataset.find(params.require(:id))
  end

  def current_doc
    Doc.find(params.require(:file_id))
  end
end
