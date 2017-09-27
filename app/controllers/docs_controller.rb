class DocsController < ApplicationController
  before_action :set_current_dataset, only: [:index, :create, :update, :destroy]
  before_action :set_current_doc,     only: [:edit, :update, :confirm_delete, :destroy]

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
  end

  def update
    doc_params = params.require(:doc).permit(:url, :name)
    @doc.update_attributes(doc_params)

    if @doc.save
      redirect_to docs_path(@dataset)
    else
      render 'edit'
    end
  end

  def confirm_delete
    flash[:alert] = "Are you sure you want to delete ‘#{@doc.name}’?"

    redirect_to docs_path(file_id: @doc.id)
  end

  def destroy
    flash[:deleted] = "Your link ‘#{@doc.name}’ has been deleted"
    @doc.destroy

    redirect_to docs_path(@dataset)
  end

  private

  def set_current_dataset
    @dataset = Dataset.find_by(name: params.require(:id)) || Dataset.find(params.require(:id))
  end

  def set_current_doc
    Doc.find(params[:file_id])
  end
end
