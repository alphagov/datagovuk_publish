class CreateOrganisationStatistics < ActiveRecord::Migration[5.1]
  def change
    create_table :organisation_statistics do |t|
      t.string :organisation_name, limit: 64
      t.string :dataset_title, limit: 256
      t.string :subject_title, limit: 64, default: 'Downloads'
      t.integer :value, default: 0
      t.string :direction, limit: 4
      t.string :since, limit: 20

      t.timestamps
    end
  end
end
