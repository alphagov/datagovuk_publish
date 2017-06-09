module DatasetsHelper
  def dataset_field(f, dataset, options)
    render 'dataset_field', f: f, dataset: dataset, field: options
  end
end
