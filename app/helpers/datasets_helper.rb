module DatasetsHelper
  def dataset_field(f, dataset, options)
    render 'dataset_field', f: f, dataset: dataset, field: options
  end

  FRIENDLY_FREQUENCIES = {
    'never' => 'One-off'
  }

  def friendly_frequency(frequency)
    FRIENDLY_FREQUENCIES.fetch(frequency, 'One-off')
  end
end
