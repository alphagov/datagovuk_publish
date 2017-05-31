class CreateInspireDatasets < ActiveRecord::Migration[5.1]
  def change
    create_table :inspire_datasets do |t|
      t.string :bbox_east_long
      t.string :bbox_west_long
      t.string :bbox_north_lat
      t.string :bbox_south_lat
      t.text :coupled_resource
      t.text :dataset_reference_date
      t.string :frequency_of_update
      t.string :guid
      t.text :harvest_object_id
      t.text :harvest_source_reference
      t.text :import_source
      t.string :metadata_date
      t.string :metadata_language
      t.text :provider
      t.string :resource_type
      t.text :responsible_party
      t.text :spatial
      t.string :spatial_data_service_type
      t.string :spatial_reference_system
      t.references :dataset, foreign_key: true

      t.timestamps
    end
  end
end
