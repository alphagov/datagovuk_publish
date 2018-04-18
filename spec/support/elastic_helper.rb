def mappings
  DatasetsIndexerService::INDEX_MAPPING
end

def delete_index
  ELASTIC.indices.delete index: "datasets-test"
rescue
  Rails.logger.debug("No test search index to delete")
end

def create_index
  ELASTIC.indices.create(index: "datasets-test",
                         body: { mappings: mappings })
rescue
  Rails.logger.debug("Could not create datasets-test index")
end
