class Legacy::OrganisationImportService
  attr_reader :legacy_organisation

  def initialize(legacy_organisation)
    @legacy_organisation = legacy_organisation
  end

  def run
    o = Organisation.find_by(name: legacy_organisation["name"]) || Organisation.new

    o.uuid = legacy_organisation["id"]
    o.name = legacy_organisation["name"]
    o.title = legacy_organisation["title"]
    o.description = legacy_organisation["description"]
    o.abbreviation = legacy_organisation["abbreviation"]
    o.replace_by = "#{legacy_organisation['replaced_by']}"
    o.contact_email = legacy_organisation["contact-email"]
    o.contact_phone = legacy_organisation["contact-phone"]
    o.contact_name = legacy_organisation["contact-name"]
    o.foi_email = legacy_organisation["foi-email"]
    o.foi_phone = legacy_organisation["foi-phone"]
    o.foi_name = legacy_organisation["foi-name"]
    o.foi_web = legacy_organisation["foi-web"]
    o.category = legacy_organisation["category"]

    if central_government?
      o.org_type = "central-government"
    elsif local_council?
      o.org_type = "local-authority"
    else
      o.org_type = "other-government-body"
    end

    groups = legacy_organisation["groups"] || []

    if groups.size != 0
      parent = groups[0]["name"]
      relationships[o.name] = parent
    end

    o.save(validate: false)
  end

  private

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
