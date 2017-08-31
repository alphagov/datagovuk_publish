class DatasetsController < ApplicationController
  before_action :authenticate_user!

  def show
    @dataset = current_dataset
    @dataset.complete!
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

  def publish
    @dataset = current_dataset
    @dataset.complete!

    if @dataset.publishable?
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
    @dataset = current_dataset
    if @dataset.published?
      @dataset.errors.add(:delete_prevent, 'Published datasets cannot be deleted')
    else
      flash[:alert] = 'Are you sure you want to delete this dataset?'
    end
    render 'show'
  end

  def destroy
    @dataset = current_dataset
    if @dataset.published?
      @dataset.errors.add(:delete_prevent, 'Published datasets cannot be deleted')
      render 'show'
    else
      flash[:deleted] = "The dataset '#{current_dataset.title}' has been deleted"
      current_dataset.destroy
      redirect_to manage_path
    end
  end

  def quality
    # A temporary page to show why some datasets are low quality
    @dataset = current_dataset

    require 'quality/quality_score_calculator'
    q = QualityScoreCalculator.new(current_dataset)

    @score = q.score
    @reasons = q.reasons
  end

  private
  def current_dataset
    Dataset.find_by(:name => params.require(:id))
  end

  def current_file
    Datafile.find(params.require(:file_id))
  end
end
