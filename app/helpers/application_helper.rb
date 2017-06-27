module ApplicationHelper
  def url_contains(action)
    url = request.path
    url.gsub(@dataset.title, '') if @dataset.title
    url.include?(action)
  end
end
