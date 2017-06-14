module ManageHelper

  SORT_UPDATES = {
    "-name" => {title: :desc},
    "name" => {title: :asc},
  }

  def manage_sort
    @name_sort = params["sort_by"] == "name" ? "-name" : "name"
  end

  def set_path(args)
    current_page?(action: 'manage_organisation') ? manage_organisation_path(args) : manage_path(args)
  end

  def sorted_datasets
    sort = params["sort_by"] || @name_sort
    @datasets.order(SORT_UPDATES[sort])
  end

end
