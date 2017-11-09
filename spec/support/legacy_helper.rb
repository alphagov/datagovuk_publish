def legacy_dataset_update_endpoint
  "#{ENV['LEGACY_HOST']}#{Legacy::Server::ENDPOINTS[:update_dataset]}"
end

def legacy_dataset_create_endpoint
  "#{ENV['LEGACY_HOST']}#{Legacy::Server::ENDPOINTS[:create_dataset]}"
end

def legacy_datafile_update_endpoint
  "#{ENV['LEGACY_HOST']}#{Legacy::Server::ENDPOINTS[:update_datafile]}"
end
