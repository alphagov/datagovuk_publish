module TasksHelper

  SORT_UPDATES = {
    "ascending" => {created_at: :asc},
    "-name" => {description: :desc},
    "name" => {description: :asc},
    "descending" => {created_at: :desc},
    "-broken-name" => {title: :desc},
    "decreasing" => {created_at: :desc},
    "increasing" => {created_at: :asc},
    "broken-name" => {title: :asc}
  }

  def manage_sort
    @date_sort          = params["update_sort_by"] == "descending" ? "ascending" : "descending"
    @update_name_sort   = params["update_sort_by"] == "name" ? "-name" : "name"
    @count_sort         = params["fix_sort_by"] == "increasing" ? "decreasing" : "increasing"
    @fix_name_sort      = params["fix_sort_by"] == "broken-name" ? "-broken-name" : "broken-name"

  end

  def sorted_update_tasks
    sort = params["update_sort_by"] || @date_sort
    @tasks.order(SORT_UPDATES[sort])
  end

  def sorted_fix_tasks
    sort = params["fix_sort_by"] || @fix_name_sort
    @broken_datasets.order(SORT_UPDATES[sort])
  end

  def broken_dataset_count
    @broken_datasets.count
  end
end
