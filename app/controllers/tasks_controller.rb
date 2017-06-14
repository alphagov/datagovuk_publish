
class TasksController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_user!
  include TasksHelper


  def my
    @organisation = current_user.primary_organisation
    @datasets = Dataset.where(organisation: @organisation.id)
    @broken_datasets = Dataset.where(organisation: @organisation.id)
    @tasks = get_tasks_for_user(current_user)
    manage_sort
  end


  def organisation
    @organisation = current_user.primary_organisation
    @datasets = Dataset.where(organisation: @organisation.id)
    @broken_datasets = Dataset.where(organisation: @organisation.id)
    @tasks = get_tasks_for_organisation(@organisation.name)
    manage_sort
  end

private

  def get_tasks_for_user(_user)
    Task.all
  end

  # For the given organisation name, find the tasks that they have in each category
  def get_tasks_for_organisation(_organisation)
    Task.all
  end

end
