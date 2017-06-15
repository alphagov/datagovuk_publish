module ManageHelper

  SORT_OPTIONS = {"-name" => {title: :desc}}
  SORT_OPTIONS.default = {title: :asc}

  def manage_sort
    @name_sort = params["sort_by"] == "name" ? "-name" : "name"
    @publish_sort = params["sort_by"] == "published" ? "draft" : "published"
  end

  def set_path(args)
    current_page?(action: 'manage_organisation') ? manage_organisation_path(args) : manage_path(args)
  end

  def sorted_datasets
    if name_sort?
      sort = params["sort_by"] || @name_sort
      @datasets.order(SORT_OPTIONS[sort])
    else
      pub, draft = group_by_publish(true), group_by_publish(false)
      params["sort_by"] == "published" ? pub + draft : draft + pub
    end
  end

  def group_by_publish(bool)
    @datasets.where(published: bool).order(SORT_OPTIONS[''])
  end

  def name_sort?
    params["sort_by"].nil? || params["sort_by"].include?("name")
  end

end
