class AddUuidToDataset < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :uuid, :uuid
  end
end
