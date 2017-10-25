class DatasetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dataset, only: [:show, :edit, :update, :destroy,
                                     :publish, :confirm_delete, :quality]

  def show
    @dataset.complete!

    if request.path != dataset_path(@dataset)
      return redirect_to @dataset, status: :moved_permanently
    end
  end

  def new
    @dataset = Dataset.new
  end

  def edit
  end

  def create
    @dataset = Dataset.new(dataset_params)
    @dataset.creator_id = current_user.id
    @dataset.organisation = current_user.primary_organisation

    if @dataset.save
      redirect_to new_dataset_licence_path(@dataset)
    else
      render :new
    end
  end

  def update
    if @dataset.update(dataset_params)
      redirect_to @dataset
    else
      render :edit
    end
  end

  def publish
    @dataset.complete!

    if @dataset.publishable?
      if @dataset.published?
        flash[:success] = I18n.t 'dataset_updated'
        update_on_legacy
      else
        flash[:success] = I18n.t 'dataset_published'
        create_on_legacy
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

  def update_on_legacy
    PublishToLegacyUpdateMetadataWorker.perform_async(@dataset.id)
  end

  def set_dataset
    @dataset = Dataset.friendly.find(params[:id])
  end

  def dataset_params
    params.require(:dataset).permit(:title, :summary, :description)
  end
end
