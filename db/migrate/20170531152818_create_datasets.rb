class CreateDatasets < ActiveRecord::Migration[5.1]
  def change
    create_table :datasets do |t|
      t.string :name
      t.string :title
      t.string :summary
      t.text :description
      t.string :dataset_type
      t.integer :organisation_id
      t.string :licence
      t.text :licence_other
      t.string :location1
      t.string :location2
      t.string :location3
      t.text :frequency
      t.integer :creator_id
      t.integer :owner_id
      t.boolean :published
      t.datetime :published_date
      t.boolean :harvested
      t.text :legacy_metadata

      t.timestamps
    end
  end
end
