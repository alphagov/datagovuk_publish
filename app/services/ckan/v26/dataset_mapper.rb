module CKAN
  module V26
    class DatasetMapper
      def call(package)
        {
          title: package.get("title"),
          summary: build_notes(package),
          legacy_name: package.get("name"),
          organisation_id: lookup_organisation(package),
          created_at: package.get("metadata_created"),
          updated_at: package.get("metadata_modified"),
          harvested: harvested?(package),
          contact_name: package.get("contact-name"),
          contact_email: package.get("contact-email"),
          foi_name: package.get("foi-name"),
          foi_email: package.get("foi-email"),
          foi_web: package.get("foi-web"),
          location1: build_location(package),
          licence_code: package.get("license_id"),
          licence_title: Licence.lookup(package.get("license_id")).title,
          licence_url: Licence.lookup(package.get("license_id")).url,
          licence_custom: package.get_extra("licence"),
          topic_id: lookup_topic(package),
          schema_id: package.get("schema")&.first&.fetch("id") || package.get("schema-vocabulary"),
          status: "published",
        }
      end

    private

      def lookup_organisation(package)
        Organisation.find_by(uuid: package.get("owner_org"))&.id
      end

      def lookup_topic(package)
        return unless package.get("theme-primary")

        name = package.get("theme-primary")
          .gsub('&', 'and').tr(' ', '-').downcase

        Topic.find_by(name: name)&.id
      end

      def harvested?(package)
        package.get_extra("harvest_object_id").present? || package.get_harvest("harvest_object_id").present?
      end

      def build_location(package)
        Array(package.get("geographic_coverage")).map(&:titleize).join(', ')
      end

      def build_notes(package)
        return "No description provided" if package.get("notes").blank?
        package.get("notes")
      end
    end
  end
end
