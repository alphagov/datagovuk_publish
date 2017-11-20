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

  def foi_contact_details(dataset)
    "#{dataset.foi_name} (#{dataset.foi_email})"
  end
end
