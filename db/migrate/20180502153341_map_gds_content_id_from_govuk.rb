class MapGdsContentIdFromGovuk < ActiveRecord::Migration[5.1]
  def change
    org = Organisation.find_by(name: 'government-digital-service')
    return unless org
    org.update_attribute(:govuk_content_id, 'af07d5a5-df63-4ddc-9383-6a666845ebe9')
  end
end
