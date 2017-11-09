class Legacy::Dataset < SimpleDelegator
  ENDPOINTS = {
    update: "/api/3/action/package_patch",
    create: "/api/3/action/package_create"
  }

  def update
    Legacy::Server.new.update(path_for_action(:update), update_payload)
  end

  def create
    Legacy::Server.new.create(path_for_action(:create), create_payload)
  end

  def update_payload
    { "id" => ckan_uuid,
      "name" => legacy_name,
      "title" => title,
      "notes" => summary,
      "description" => summary,
      "organization" => { "name" => organisation.name },
      "update_frequency" => legacy_frequency,
      "update_frequency-other" => legacy_frequency,
      "extras" => [{"key" => "update_frequency",
                    "value" => legacy_frequency},
                    {"key" => "update_frequency-other",
                              "value" => legacy_frequency}
                  ],
      "unpublished" => !published?,
      "metadata_modified" => last_updated_at,
      "geographic_coverage" => [(location1 || "").downcase],
      "license_id" => licence
    }.compact.to_json
  end

  def create_payload
    { "name" => name,
      "title" => title,
      "notes" => summary,
      "description" => summary,
      "owner_org" => organisation.uuid,
      "update_frequency" => legacy_frequency,
      "update_frequency-other" => legacy_frequency,
      "extras" => [{"key" => "update_frequency",
                    "value" => legacy_frequency},
                    {"key" => "update_frequency-other",
                              "value" => legacy_frequency},
                    {"key" => "publish_uuid",
                     "value" => uuid}
                  ],
      "geographic_coverage" => [(location1 || "").downcase],
      "license_id" => licence
    }.compact.to_json
  end

  private

  def path_for_action(action)
    ENDPOINTS[action]
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
