class TasksController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_publishing_user!

  def index
    @organisation = current_publishing_user.primary_organisation
    @datasets = Dataset.all
    @tasks = get_tasks_for_user(current_publishing_user)
    @datasetsUpdate = @datasets[0,1]
    @datasetsBroken = @datasets[0,1]
  end


  def organisation
    @organisation = current_publishing_user.primary_organisation
    @datasets = Dataset.all
    @tasks = get_tasks_for_organisation(@organisation.name)
    @datasetsUpdate = @datasets[0,1]
    @datasetsBroken = @datasets[0,1]
  end

private

  def get_tasks_for_user(user)
    Task.all
  end

  # For the given organisation name, find the tasks that they have in each category
  def get_tasks_for_organisation(organisation)
    Task.all
  end

end
