class DatasetsController < ApplicationController
  before_action :set_dataset,
                only: %i[show edit update destroy publish confirm_delete]

  def show
    authorize!(:read, @dataset)

    if request_to_outdated_url?
      return redirect_to newest_dataset_path, status: :moved_permanently
    end
  end

  def new
    @dataset = Dataset.new
  end

  def edit
    authorize!(:update, @dataset)
  end

  def create
    @dataset = Dataset.new(dataset_params)
    @dataset.creator_id = current_user.id
    @dataset.organisation = current_user.primary_organisation

    if @dataset.save
      redirect_to new_dataset_topic_path(@dataset.uuid, @dataset.name)
    else
      render :new
    end
  end

  def update
    @dataset.assign_attributes(dataset_params)
    if @dataset.save(context: :dataset_form)
      redirect_to dataset_path(@dataset.uuid, @dataset.name)
    else
      render :edit
    end
  end

  def publish
    flash[:success] = I18n.t 'dataset.published'
    flash[:extra] = @dataset

    @dataset.publish
    redirect_to manage_path
  end

  def confirm_delete
    flash[:alert] = 'Are you sure you want to delete this dataset?'
    render :show
  end

  def destroy
    flash[:deleted] = "The dataset '#{@dataset.title}' has been deleted"
    @dataset.unpublish
    @dataset.destroy
    redirect_to manage_path
  end

private

  def set_dataset
    @dataset = Dataset.find_by!(uuid: params[:uuid])
  end

  def dataset_params
    params.require(:dataset).permit(:title, :summary, :description)
  end

  def request_to_outdated_url?
    request.path != newest_dataset_path
  end

  def newest_dataset_path
    dataset_path(@dataset.uuid, @dataset.name)
  end
end
