class Datasets::TopicsController < ApplicationController
  def new
    @dataset = current_dataset
    @topics = sorted_topics
  end

  def edit
    @dataset = current_dataset
    @topics = sorted_topics
  end

  def create
    @dataset = current_dataset
    @dataset.topic_id = topic_params[:topic_id]

    if @dataset.save(context: :dataset_topic_form)
      redirect_to new_dataset_licence_path(@dataset.uuid, @dataset.name)
    else
      @topics = sorted_topics
      render :new
    end
  end

  def update
    @dataset = current_dataset
    @dataset.topic_id = topic_params[:topic_id]

    if @dataset.save(context: :dataset_form)
      redirect_to dataset_path(@dataset.uuid, @dataset.name)
    else
      render :edit
    end
  end

private

  def current_dataset
    Dataset.find_by(uuid: params[:uuid])
  end

  def sorted_topics
    Topic.all.order(:title)
  end

  def topic_params
    params.fetch(:dataset, {}).permit(:topic_id)
  end
end
