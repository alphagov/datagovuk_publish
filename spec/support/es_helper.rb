def get_from_es(uuid)
  client = Dataset.__elasticsearch__.client
  client.get(index: Dataset.index_name, id: uuid)["_source"]
end

def in_es_format(value)
  JSON.parse(value.to_json)
end
