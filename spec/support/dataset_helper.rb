def last_updated_dataset
  Dataset.order(:updated_at).last
end

def click_change(property)
  properties = {
    title: 0,
    summary: 1,
    additional_info: 2,
    topic: 3,
    licence: 4,
    location: 5,
    frequency: 6,
    datalinks: 7,
    documentation: 8
  }
  index = properties[property]
  all(:link, "Change")[index].click
end

def click_dataset(dataset)
  find(:xpath, "//a[@href='#{dataset_path(dataset.uuid, dataset.name)}']").click
end
