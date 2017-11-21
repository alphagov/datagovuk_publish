class IndexDeleter

  def initialize(args)
    @index_alias = args[:index_alias]
    @client = args[:client]
    @logger = args[:logger]
  end

  def run
    aliases = client.indices.get_aliases.keys
    indexes_to_be_deleted = prepare_indexes_for_deletion aliases
    delete indexes_to_be_deleted
  rescue => e
    msg = "Failed to delete alias.\n#{e.message}"
    logger.error msg
    Raven.capture_error msg
  end

  private

  attr_reader :client, :index_alias, :logger

  def prepare_indexes_for_deletion(aliases)
    # Ensure that the three most recent indexes are kept
    aliases
      .select { |alias_name| alias_name.include? index_alias }
      .sort_by { |alias_name| Time.parse(alias_name.gsub(/"#{index_alias}_"/, '')) }
      .reverse
      .slice(2...-1)
  end

  def delete(indexes)
    indexes.each do |index|
      client.indices.delete index: index
      logger.info "Deleted #{index}"
    end
  end
end
