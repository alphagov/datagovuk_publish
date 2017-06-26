module DatasetsHelper
  def dataset_field(f, dataset, options)
    render 'dataset_field', f: f, dataset: dataset, field: options
  end

  FRIENDLY_FREQUENCIES = {
    'never' => 'One-off'
  }

  def friendly_frequency(frequency)
    FRIENDLY_FREQUENCIES.fetch(frequency, frequency.humanize)
  end

  def creating?
    url_contains('/new')
  end

  def editing?
    url_contains('/edit')
  end

  def update_method
    if creating?
      'post'
    else
      'put'
    end
  end

  private
  def url_contains(action)
    url = request.path
    url.gsub(@dataset.title, '') if @dataset.title
    url.include?(action)
  end
end
