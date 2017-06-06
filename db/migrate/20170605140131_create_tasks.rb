class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.references :organisation, foreign_key: true
      t.integer :quantity, default: 0
      t.string :required_permission_name
      t.string :description, limit: 128, default: "", null: true
      t.string :category, limit: 20
      t.string :owning_organisation, limit: 128, null: true
      t.uuid :related_object_id, null: true
      t.timestamps
    end
  end
end
