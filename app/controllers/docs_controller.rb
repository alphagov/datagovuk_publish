class DocsController < ApplicationController
  before_action :set_current_dataset, only: [:index, :new, :create, :update, :destroy]
  before_action :set_current_doc,     only: [:edit, :update, :confirm_delete, :destroy]

  def index
    @datafiles = @dataset.docs
  end

  def new
    @doc = @dataset.docs.build
  end

  def create
    @doc = @dataset.docs.build(doc_params)

    if @doc.save
      redirect_to docs_path(@dataset)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @doc.update(doc_params)
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
    @dataset = Dataset.find_by(name: params[:id]) || Dataset.find(params[:id])
  end

  def set_current_doc
    @doc = Doc.find(params[:id])
  end

  def doc_params
    params.require(:doc).permit(:url, :name)
  end
end
