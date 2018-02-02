class AddShortIdToDataset < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :short_id, :string, unique: true
    add_index :datasets, :short_id, unique: true
  end
end
