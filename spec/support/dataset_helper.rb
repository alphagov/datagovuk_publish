def last_updated_dataset
  Dataset.order(:updated_at).last
end

def click_change(property)
  properties = %i(
    title
    summary
    additional_info
    topic
    licence
    location
    frequency
    datalinks
    documentation
  )

  all(:link, "Change")[properties.index(property)].click
end

def click_dataset(dataset)
  find(:xpath, "//a[@href='#{dataset_path(dataset.uuid, dataset.name)}']").click
end
