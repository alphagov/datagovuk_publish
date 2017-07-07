module DatasetsHelper
  def dataset_field(f, dataset, options)
    render '/datasets/dataset_field', f: f, dataset: dataset, field: options
  end

  FRIENDLY_FREQUENCIES = {
    'never' => 'One-off'
  }

  def friendly_frequency(frequency)
    if frequency
      FRIENDLY_FREQUENCIES.fetch(frequency, frequency.humanize)
    else
      ""
    end
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
end
