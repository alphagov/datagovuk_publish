class RemoveUnusedDatasetFields < ActiveRecord::Migration[5.1]
  def change
    remove_column :datasets, :owner_id
    remove_column :datasets, :legacy_metadata
  end
end
