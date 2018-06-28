class MapGdsContentIdFromGovuk < ActiveRecord::Migration[5.1]
  def change
    org = Organisation.find_or_create_by(uuid: 'af07d5a5-df63-4ddc-9383-6a666845ebe9',
                                         name: 'government-digital-services')

    org.update_attribute(:govuk_content_id, 'af07d5a5-df63-4ddc-9383-6a666845ebe9')
  end
end
