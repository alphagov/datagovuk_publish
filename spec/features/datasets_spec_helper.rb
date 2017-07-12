def edit_dataset(dataset)
  datasets = {
    :published_dataset => 0,
    :unpublished_dataset => 1,
    :unfinished_dataset => 2
  }
  index = datasets[dataset]
  all(:link, "Edit")[index].click
end

def click_change(property)
  properties = {
    :title => 0,
    :summary => 1,
    :additional_info => 2,
    :licence => 3,
    :location => 4,
    :frequency => 5,
    :datalinks => 6,
    :documentation => 7
  }
  index = properties[property]
  all(:link, "Change")[index].click
end
