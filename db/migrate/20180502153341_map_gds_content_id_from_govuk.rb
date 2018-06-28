class MapGdsContentIdFromGovuk < ActiveRecord::Migration[5.1]
  def change
    org = Organisation.find_or_create_by(uuid: '90aefa0d-0e92-4895-a7fd-c1adb2b3f14f',
                                         name: 'government-digital-service')

    org.update_attribute(:govuk_content_id, 'af07d5a5-df63-4ddc-9383-6a666845ebe9')
    org.update_attribute(:title, 'Government Digital Service')
  end
end
