def legacy_dataset_update_endpoint
  "#{ENV['LEGACY_HOST']}#{Legacy::Dataset::ENDPOINTS[:update]}"
end

def legacy_dataset_create_endpoint
  "#{ENV['LEGACY_HOST']}#{Legacy::Dataset::ENDPOINTS[:create]}"
end

def legacy_datafile_update_endpoint
  "#{ENV['LEGACY_HOST']}#{Legacy::Datafile::ENDPOINTS[:update]}"
end
