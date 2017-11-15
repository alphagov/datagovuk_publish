def legacy_dataset_update_endpoint
  Legacy::Server.url_for(resource_name: "dataset", action: "update")
end

def legacy_dataset_create_endpoint
  Legacy::Server.url_for(resource_name: "dataset", action: "create")
end

def legacy_datafile_update_endpoint
  Legacy::Server.url_for(resource_name: "datafile", action: "update")
end

def legacy_datafile_create_endpoint
  Legacy::Server.url_for(resource_name: "datafile", action: "create")
end
