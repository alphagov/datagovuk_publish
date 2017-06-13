module TasksHelper

  SORT_TOGGLES = {
    "broken-name"=>"-broken-name",
    "-broken-name"=>"broken-name",
    "increasing"=>"decreasing",
    "decreasing"=>"increasing",
    "descending"=>"ascending",
    "ascending"=>"descending",
    "-name"=>"name",
    "name"=>"-name"
  }
  
  def manage_sort
    @date_sort          = "ascending"
    @update_name_sort   = "name"
    @fix_name_sort      = "broken-name"
    @count_sort         = "decreasing"

    ["update_sort_by","fix_sort_by"].each do |key|
      toggle_sort(params[key])
    end
  end

  def toggle_sort(param)
    if (param == "broken-name") || (param == "-broken-name")
      @fix_name_sort = SORT_TOGGLES[param]
    elsif (param == "decreasing") || (param == "increasing")
      @count_sort = SORT_TOGGLES[param]
    elsif (param == "descending") || (param == "ascending")
      @date_sort = SORT_TOGGLES[param]
    elsif (param == "name") || (param == "-name")
      @update_name_sort = SORT_TOGGLES[param]
    end
  end

  def sorted_update_tasks
    if params["update_sort_by"] == "ascending"
      @tasks.order(created_at: :asc)
    elsif params["update_sort_by"] == "-name"
      @tasks.order(description: :desc)
    elsif params["update_sort_by"] == "name"
      @tasks.order(:description)
    else
      @tasks.order(created_at: :desc)
    end
  end

  def sorted_fix_tasks
    if params["fix_sort_by"] == "-broken-name"
      @broken_datasets.order(title: :desc)
    elsif params["fix_sort_by"] == "decreasing"
      #TODO: should be ordered by broken link count, created_at just a place holder
      @broken_datasets.order(created_at: :desc)
    elsif params["fix_sort_by"] == "increasing"
      # TODO: should be ordered by broken link count, created_at just a place holder
      @broken_datasets.order(created_at: :asc)
    else
      @broken_datasets.order(title: :asc)
    end
  end

  def broken_dataset_count
    @broken_datasets.count
  end
end
