class Legacy::OrganisationImportService
  attr_reader :legacy_organisation

  def initialize(legacy_organisation)
    @legacy_organisation = legacy_organisation
  end

  def run
    organisation.update_attributes!(organisation_attributes)
  end

  def organisation_attributes
    {
      uuid: legacy_organisation["id"],
      name: legacy_organisation["name"],
      title: legacy_organisation["title"],
      description: legacy_organisation["description"],
      abbreviation: legacy_organisation["abbreviation"],
      replace_by: legacy_organisation['replaced_by'],
      contact_email: legacy_organisation["contact-email"],
      contact_phone: legacy_organisation["contact-phone"],
      contact_name: legacy_organisation["contact-name"],
      foi_email: legacy_organisation["foi-email"],
      foi_phone: legacy_organisation["foi-phone"],
      foi_name: legacy_organisation["foi-name"],
      foi_web: legacy_organisation["foi-web"],
      category: legacy_organisation["category"],
      org_type: get_org_type,
      parent: get_parent_organisation
    }
  end

  private

  def organisation
    @organisation ||= Organisation.find_or_initialize_by(name: legacy_organisation["name"])
  end

  def get_parent_organisation
    Organisation.find_by(name: groups[0]["name"]) if groups.any?
  end

  def groups
    legacy_organisation.fetch("groups", [])
  end

  def get_org_type
    return "central-government" if central_government?
    return  "local-authority" if local_council?
    "other-government-body"
  end

  def central_government?
    %w("ministerial-department", "non-ministerial-department",
        "devolved", "executive-ndpb", "advisory-ndpb",
        "tribunal-ndpb", "executive-agency",
        "executive-office", "gov-corporation").include? legacy_organisation["category"]
  end

  def local_council?
    legacy_organisation["category"] == "local-council"
  end
end
