def click_change(property)
  properties = {
    title: 0,
    summary: 1,
    additional_info: 2,
    licence: 3,
    location: 4,
    frequency: 5,
    datalinks: 6,
    documentation: 7
  }
  index = properties[property]
  all(:link, "Change")[index].click
end

def click_dataset(dataset)
  find(:xpath, "//a[@href='#{dataset_path(dataset.uuid, dataset.name)}']").click
end
