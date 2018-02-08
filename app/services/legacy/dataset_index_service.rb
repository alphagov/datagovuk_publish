class Legacy::DatasetIndexService
  def index(legacy_dataset_id)
    dataset = Dataset.find_by!(uuid: legacy_dataset_id)

    dataset.__elasticsearch__.index_document(index: ::Dataset.__elasticsearch__.index_name,
                                             type: ::Dataset.__elasticsearch__.document_type,
                                             id: dataset.id, body: dataset.as_indexed_json)
  end

  def remove_from_index(legacy_dataset_id)
    dataset = Dataset.find_by!(uuid: legacy_dataset_id)

    begin
      dataset.__elasticsearch__.delete_document({
                                                index: ::Dataset.__elasticsearch__.index_name,
                                                type: ::Dataset.__elasticsearch__.document_type,
                                                id: dataset.id
                                              })
    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      Rails.logger.warn e.message
    end
  end
end
