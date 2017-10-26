class Legacy::Dataset < SimpleDelegator

  def metadata_json
    ckan_dataset = {
      "id" => uuid,
      "name" => name,
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
      "license_id" => licence,
      "resources" => build_resources(datafiles)
    }.compact
    extend_extras(ckan_dataset).to_json
  end

  def update
    Legacy::Server.new.update(metadata_json)
  end

  private

  def build_resources(datafiles)
    # ckan_resources =
      datafiles.map do |datafile|
        Legacy::Datafile.new(datafile).datafile_json
      end

    # legacy_resources = get_response("resources")
    #
    #   if legacy_resources
    #     resources = ckan_resources.concat(legacy_resources)
    #     resources.sort_by{|t| t["created"]}.uniq!{ |res| res["id"]}
    #   end
    # resources
  end


  def get_response(key)
    dataset_response = Legacy::Server.new.show(uuid)
    return if dataset_response == nil

    JSON.parse(dataset_response.body)["result"][key]
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

    # legacy_extras = get_response("extras")
    # if legacy_extras
    #   legacy_extras.delete_if{ |extra| extra.has_key?('update_frequency') || extra.has_key?('update_frequency') }
    #   ckan_dataset["extras"].concat(legacy_extras)
    # end
    ckan_dataset
  end

  def convert_freq_to_legacy_format(frequency)
    FREQUENCY_MAP.fetch(frequency, "")
  end

  def custom_frequency
    return frequency if ['daily', 'weekly', 'one-off'].include?(frequency)
  end

  FREQUENCY_MAP =
    { 'annually' => 'annual',
      'quarterly' => 'quarterly',
      'monthly' => 'monthly',
      'daily' => 'other',
      'weekly' => 'other',
      'never' => 'never',
      'discontinued' => 'discontinued',
      'one-off' => 'other'
    }
end
