class AddUuidToInspireDataset < ActiveRecord::Migration[5.1]
  def change
    add_column :inspire_datasets, :uuid, :uuid
    add_index :inspire_datasets, :uuid
  end
end
