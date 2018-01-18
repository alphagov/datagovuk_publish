# coding: utf-8
class Datasets::DocsController < ApplicationController
  before_action :set_dataset, only: [:index, :new, :create, :edit, :update, :confirm_delete, :destroy]
  before_action :set_doc,     only: [:edit, :update, :confirm_delete, :destroy]

  def index
    @docs = @dataset.docs
  end

  def new
    @doc = @dataset.docs.build
  end

  def create
    @doc = @dataset.docs.build(doc_params)
    @doc.documentation = true

    if @doc.save
      redirect_to dataset_docs_path(@dataset.uuid, @dataset.name)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @doc.update(doc_params)
      redirect_to dataset_docs_path(@dataset.uuid, @dataset.name)
    else
      render :edit
    end
  end

  def confirm_delete
    flash[:alert] = "Are you sure you want to delete ‘#{@doc.name}’?"
    flash[:doc_id] = @doc.id

    redirect_to dataset_docs_path(@dataset.uuid, @dataset.name)
  end

  def destroy
    flash[:deleted] = "Your link ‘#{@doc.name}’ has been deleted"
    @doc.destroy

    redirect_to dataset_docs_path(@dataset.uuid, @dataset.name)
  end

  private

  def set_dataset
    @dataset = Dataset.find_by(uuid: params[:uuid])
  end

  def set_doc
    @doc = Doc.find(params[:id])
  end

  def doc_params
    params.require(:doc).permit(:url, :name)
  end
end
