class AddLegacyNameToDataset < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :legacy_name, :string
  end
end
