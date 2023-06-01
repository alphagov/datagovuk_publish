module DatasetsHelper
  def dataset_field(f, dataset, options) # rubocop:disable Naming/MethodParameterName
    render "/datasets/dataset_field", f:, dataset:, field: options
  end

  FRIENDLY_FREQUENCIES = {
    "never" => "One-off",
  }.freeze

  def friendly_frequency(frequency)
    if frequency
      FRIENDLY_FREQUENCIES.fetch(frequency, frequency.humanize)
    else
      ""
    end
  end
end
