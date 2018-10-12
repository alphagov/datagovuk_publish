class AddSchemaIdToDataset < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :schema_id, :string
  end
end
