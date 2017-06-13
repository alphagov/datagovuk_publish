module TasksHelper

  def manage_sort

    @date_sort          = "descending"
    @update_name_sort   = "name"
    @fix_name_sort      = "broken-name"
    @count_sort         = "decreasing"

    case params["update_sort_by"]
    when "descending"
      @date_sort = "ascending"
    when "ascending"
      @date_sort = "descending"
    when "name"
      @update_name_sort = "-name"
    else
      @update_name_sort = "name"
    end

    case params["fix_sort_by"]
    when "broken-name"
      @fix_name_sort = "-broken-name"
    when "-broken-name"
      @fix_name_sort = "broken-name"
    when "decreasing"
      @count_sort = "increasing"
    else
      @count_sort = "decreasing"
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
