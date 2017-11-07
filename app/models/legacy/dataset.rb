class Legacy::Dataset < SimpleDelegator
  ENDPOINTS = {
    update: "/api/3/action/package_patch"
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
      "update_frequency" => legacy_frequency,
      "update_frequency-other" => legacy_frequency,
      "extras" => [{"key" => "update_frequency",
                    "package_id" => uuid,
                    "value" => legacy_frequency},
                    {"key" => "update_frequency-other",
                              "package_id" => uuid,
                              "value" => legacy_frequency}
                  ],
      "unpublished" => !published?,
      "metadata_created" => created_at,
      "metadata_modified" => last_updated_at,
      "geographic_coverage" => [(location1 || "").downcase],
      "license_id" => licence
    }.compact.to_json
  end

  private

  def path
    ENDPOINTS[:update]
  end

  def legacy_frequency
    FREQUENCY_MAP.fetch(frequency, "")
  end

  FREQUENCY_MAP =
    { 'annually' => 'annual',
      'financial-year' => 'financial year',
      'quarterly' => 'quarterly',
      'monthly' => 'monthly',
      'daily' => 'daily',
      'never' => 'never',
      'discontinued' => 'discontinued',
    }
end
