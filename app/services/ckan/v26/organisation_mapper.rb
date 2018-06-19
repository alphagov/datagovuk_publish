module CKAN
  module V26
    class OrganisationMapper
      def call(ckan_org)
        {
          uuid: ckan_org.get("id"),
          title: ckan_org.get("title"),
          contact_email: ckan_org.get("contact-email"),
          contact_name: ckan_org.get("contact-name"),
          foi_email: ckan_org.get("foi-email"),
          foi_web: ckan_org.get("foi-web"),
          foi_name: ckan_org.get("foi-name"),
          category: ckan_org.get("category")
        }
      end
    end
  end
end
