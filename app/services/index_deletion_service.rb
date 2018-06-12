class IndexDeletionService
  NUMBER_OF_INDICES_TO_KEEP = 3

  def initialize(args)
    @index_alias = args[:index_alias]
    @client = args[:client]
    @logger = args[:logger]
    @indices_to_keep = args[:indices_to_keep] || NUMBER_OF_INDICES_TO_KEEP
  end

  def run
    indexes = client.indices.get_aliases.keys
    indexes_to_be_deleted = select_indexes_for_deletion(indexes)
    delete(indexes_to_be_deleted)
  rescue StandardError => e
    msg = "Failed to delete old indexes.\n#{e.message}"
    logger.error msg
    Raven.capture_error msg
  end

private

  attr_reader :client, :index_alias, :logger

  def select_indexes_for_deletion(indexes)
    ordered_indexes = indexes
                        .select { |index_name| index_name.include? "#{index_alias}_" }
                        .sort_by { |index_name| Time.parse(index_name.gsub(/"#{index_alias}_"/, '')) }
                        .reverse

    # Ensure that the three most recent indexes are not deleted
    indexes_to_keep = ordered_indexes.take(@indices_to_keep)

    ordered_indexes - indexes_to_keep
  end

  def delete(indexes)
    indexes.each do |index|
      client.indices.delete index: index
      logger.info "Deleted #{index}"
    end
  end
end
