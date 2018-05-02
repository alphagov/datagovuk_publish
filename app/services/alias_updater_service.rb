class AliasUpdaterService
  def initialize(args)
    @new_index_name = args[:new_index_name]
    @index_alias = args[:index_alias]
    @client = args[:client]
    @logger = args[:logger]
  end

  def run
    assign_alias_to_new_index
    @logger.info "Alias '#{@index_alias}' -> '#{@new_index_name}'"
  end

private

  def assign_alias_to_new_index
    @client.indices.update_aliases body: {
      actions: remove_index_actions + add_index_actions
    }
  rescue StandardError => e
    msg = "Could not update alias.\n #{e.message}"
    @logger.error msg
    Raven.capture_exception msg
  end

  def remove_index_actions
    active_indices.keys.map do |index_name|
      { remove: { index: index_name, alias: @index_alias } }
    end
  end

  def add_index_actions
    [{ add: { index: @new_index_name, alias: @index_alias } }]
  end

  def active_indices
    @client.indices.get_aliases.select do |_, results|
      results["aliases"].keys.include? @index_alias
    end
  end
end
