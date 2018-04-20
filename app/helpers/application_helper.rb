module ApplicationHelper
  def url_contains(action)
    url = request.path
    url.gsub(@dataset.title, '') if @dataset.title
    url.include?(action)
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    css_class = "dgu-sortable-column__heading__#{direction}"

    link_to title, { sort: column, direction: direction }, class: css_class
  end

  def find_url(dataset_uuid, dataset_name)
    "https://#{ENV['FIND_URL'] || ''}/dataset/#{dataset_uuid}/#{dataset_name}"
  end
end
