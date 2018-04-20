module TasksHelper
  SORT_UPDATES = {
    "ascending" => { created_at: :asc },
    "-name" => { description: :desc },
    "name" => { description: :asc },
    "descending" => { created_at: :desc },
    "-broken-name" => { description: :desc },
    "decreasing" => { created_at: :desc },
    "increasing" => { created_at: :asc },
    "broken-name" => { description: :asc }
  }.freeze

  def manage_sort
    @date_sort          = params["update_sort_by"] == "descending" ? "ascending" : "descending"
    @update_name_sort   = params["update_sort_by"] == "name" ? "-name" : "name"
    @count_sort         = params["fix_sort_by"] == "increasing" ? "decreasing" : "increasing"
    @fix_name_sort      = params["fix_sort_by"] == "broken-name" ? "-broken-name" : "broken-name"
  end

  def sorted_update_tasks
    sort = params["update_sort_by"] || @date_sort
    @update_dataset_tasks.order(SORT_UPDATES[sort])
  end

  def sorted_broken_tasks
    sort = params["fix_sort_by"] || @fix_name_sort
    @broken_dataset_tasks.order(SORT_UPDATES[sort])
  end

  def broken_dataset_count
    @broken_dataset_tasks.count
  end
end
