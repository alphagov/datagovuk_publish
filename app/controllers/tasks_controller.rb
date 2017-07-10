
class TasksController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_user!
  include TasksHelper


  def my
    @organisation = current_user.primary_organisation
    @datasets = Dataset.where(organisation: @organisation.id)
    @broken_dataset_tasks = get_tasks(@organisation, 'broken')
    @update_dataset_tasks = get_tasks(@organisation, 'overdue')
    manage_sort
  end


  def organisation
    @organisation = current_user.primary_organisation
    @datasets = Dataset.where(organisation: @organisation.id)
    # @broken_dataset_tasks = @datasets.joins(:datafiles).merge(Datafile.where(broken:true))
    @broken_dataset_tasks = get_tasks(@organisation, 'broken')
    @update_dataset_tasks = get_tasks(@organisation, 'overdue')
    manage_sort
  end

private

  def get_tasks(organisation, category)
    Task.where(organisation: organisation.id, category: category)
  end

end
