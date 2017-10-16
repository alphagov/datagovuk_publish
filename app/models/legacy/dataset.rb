class Legacy::Dataset < SimpleDelegator
  def json_metadata
    {
      'id': uuid,
      'name' => name,
      'title' => title,
      'notes' => summary,
      'description' => summary,
      'organization' => {
        'name' => organisation.name
      },
      'update_frequency' => convert_freq_to_legacy_format(frequency),
      'unpublished' => !published?,
      'metadata_created' => created_at,
      'metadata_modified' => last_updated_at,
      'geographic_coverage' => [location1.to_s.downcase],
      'license_id' => licence,
      'update_frequency-other' => custom_frequency
    }.compact.to_json
  end

  def update
    Legacy::Server.new.put(json_metadata)
  end

  private

  def custom_frequency
    return frequency if ['daily', 'weekly', 'one-off'].include?(frequency)
  end

  def convert_freq_to_legacy_format(frequency)
    FREQUENCY_MAP.fetch(frequency, "")
  end

  FREQUENCY_MAP = {
    'daily' => 'other',
    'weekly' => 'other',
    'monthly' => 'monthly',
    'quarterly' => 'quarterly',
    'annually' => 'annual' ,
    'never' => 'never',
    'discontinued' => 'discontinued',
    'one-off' => 'other'
  }
end
