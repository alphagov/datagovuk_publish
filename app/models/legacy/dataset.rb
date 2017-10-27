class Legacy::Dataset < SimpleDelegator
  ENDPOINTS = {
    patch: "/api/3/action/package_patch"
  }

  def update
    Legacy::Server.new.update(path, payload)
  end

  def payload
    ckan_dataset = {
      "id" => uuid,
      "name" => legacy_name,
      "title" => title,
      "notes" => summary,
      "description" => summary,
      "organization" => { "name" => organisation.name },
      "update_frequency" => convert_freq_to_legacy_format(frequency),
      "update_frequency-other" => custom_frequency,
      "extras" => [{"key" => "update_frequency",
                    "package_id" => uuid,
                    "value" => convert_freq_to_legacy_format(frequency)}
                  ],
      "unpublished" => !published?,
      "metadata_created" => created_at,
      "metadata_modified" => last_updated_at,
      "geographic_coverage" => [(location1 || "").downcase],
      "license_id" => licence
    }.compact
    extend_extras(ckan_dataset).to_json
  end

  private

  def path
    ENDPOINTS[:patch]
  end

  def extend_extras(ckan_dataset)
    if ckan_dataset["update_frequency"] == 'other'
      extra = {
        "key" => "update_frequency-other",
        "package_id" => uuid,
        "value" => ckan_dataset["update_frequency-other"]
      }
      ckan_dataset["extras"].push(extra)
    end
    ckan_dataset
  end

  def convert_freq_to_legacy_format(frequency)
    FREQUENCY_MAP.fetch(frequency, "")
  end

  def custom_frequency
    return frequency if ['daily', 'one-off'].include?(frequency)
  end

  FREQUENCY_MAP =
    { 'annually' => 'annual' ,
      'quarterly' => 'quarterly',
      'monthly' => 'monthly',
      'daily' => 'other',
      'never' => 'never',
      'discontinued' => 'discontinued',
      'one-off' => 'other'
    }
end
