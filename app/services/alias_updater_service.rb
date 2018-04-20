class AliasUpdaterService
  def initialize(args)
    @new_index_name = args[:new_index_name]
    @index_alias = args[:index_alias]
    @client = args[:client]
    @logger = args[:logger]
  end

  def run
    remove_alias_from_old_index
    assign_alias_to_new_index
    logger.info "Alias '#{index_alias}' now pointing to '#{new_index_name}'"
  end

private

  attr_reader :logger, :client, :index_alias, :new_index_name

  def remove_alias_from_old_index
    client.indices.update_aliases body: {
      actions: [
        {
          remove: {
            index: Dataset.index_name,
            alias: index_alias
          }
        }
      ]
    }
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    msg = 'Alias not currently assigned to an index'
    logger.info msg
  end

  def assign_alias_to_new_index
    client.indices.update_aliases body: {
      actions: [
        {
          add: {
            index: new_index_name,
            alias: index_alias
          }
        }
      ]
    }
  rescue StandardError => e
    msg = "Could not update alias.\n #{e.message}"
    logger.error msg
    Raven.capture_exception msg
  end
end
