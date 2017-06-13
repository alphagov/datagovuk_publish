
class TasksController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_user!


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

def manage_sort

  @update_date_sort   = "descending"
  @update_name_sort   = "name"
  @fix_name_sort      = "broken-name"
  @fix_count_sort     = "decreasing"

  case params["sort_by"]

  when "descending"
    @update_date_sort = "ascending"
  when "ascending"
    @update_date_sort = "descending"
  when "name"
    @update_name_sort = "-name"
  when "-name"
    @update_name_sort = "name"
  when "broken-name"
    @fix_name_sort = "-broken-name"
  when "-broken-name"
    @fix_name_sort = "broken-name"
  when "decreasing"
    @fix_count_sort = "increasing"
  else
    @fix_count_sort = "decreasing"
  end

end

  def get_tasks_for_user(_user)
    Task.all
  end

  # For the given organisation name, find the tasks that they have in each category
  def get_tasks_for_organisation(_organisation)
    Task.all
  end

end
