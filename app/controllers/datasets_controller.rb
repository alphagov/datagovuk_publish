class DatasetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dataset, only: [:show, :edit, :update, :destroy,
                                     :publish, :confirm_delete, :destroy, :quality]

  def show
    @dataset.complete!
  end

  def new
    @dataset = Dataset.new
  end

  def edit
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
    @dataset.update_attributes(params.require(:dataset).permit(:title, :summary, :description))

    if @dataset.save
      redirect_to dataset_path(@dataset)
    else
      render 'edit'
    end
  end

  def publish
    @dataset.complete!

    if @dataset.publishable? # todo move check to Dataset#publish
      @dataset.publish

      if @dataset.published
        flash[:success] = I18n.t 'dataset_updated'
      else
        @dataset.published = true
        flash[:success] = I18n.t 'dataset_published'
      end
      @dataset.save
      flash[:extra] = @dataset
      redirect_to manage_path
    else
      render 'show'
    end
  end

  def confirm_delete
    if @dataset.published?
      @dataset.errors.add(:delete_prevent, 'Published datasets cannot be deleted')
    else
      flash[:alert] = 'Are you sure you want to delete this dataset?'
    end
    render 'show'
  end

  def destroy
    if @dataset.published?
      @dataset.errors.add(:delete_prevent, 'Published datasets cannot be deleted')
      render 'show'
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
    @dataset = Dataset.find_by(:name => params.require(:id))
  end

  def current_file
    Datafile.find(params.require(:file_id))
  end
end
