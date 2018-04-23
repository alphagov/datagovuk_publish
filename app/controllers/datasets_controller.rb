class DatasetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dataset,
                only: %i[show edit update destroy publish confirm_delete quality]

  def show
    if request_to_outdated_url?
      redirect_to newest_dataset_path, status: :moved_permanently
    end
  end

  def new
    @dataset = Dataset.new
  end

  def create
    @dataset = Dataset.new(dataset_params)
    @dataset.creator_id = current_user.id
    @dataset.organisation = current_user.primary_organisation

    if @dataset.save
      redirect_to new_dataset_licence_path(@dataset.uuid, @dataset.name)
    else
      render :new
    end
  end

  def update
    if @dataset.update(dataset_params)
      redirect_to dataset_path(@dataset.uuid, @dataset.name)
    else
      render :edit
    end
  end

  def publish
    if @dataset.publishable?
      flash[:success] = if @dataset.published?
                          I18n.t 'dataset_updated'
                        else
                          I18n.t 'dataset_published'
                        end

      @dataset.publish!

      flash[:extra] = @dataset
      redirect_to manage_path
    else
      render :show
    end
  end

  def confirm_delete
    if @dataset.published?
      @dataset.errors.add(:delete_prevent, 'Published datasets cannot be deleted')
    else
      flash[:alert] = 'Are you sure you want to delete this dataset?'
    end
    render :show
  end

  def destroy
    if @dataset.published?
      @dataset.errors.add(:delete_prevent, 'Published datasets cannot be deleted')
      render :show
    else
      flash[:deleted] = "The dataset '#{@dataset.title}' has been deleted"
      @dataset.destroy
      redirect_to manage_path
    end
  end

  def quality
    # A temporary page to show why some datasets are low quality
    require 'quality/quality_score_calculator'
    q = QualityScoreCalculator.new(@dataset)

    @score = q.score
    @reasons = q.reasons
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
