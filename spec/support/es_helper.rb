def get_from_es(id)
  client = Dataset.__elasticsearch__.client
  client.get(index: Dataset.index_name, id: id)["_source"]
end

def in_es_format(value)
  JSON.parse(value.to_json)
end
