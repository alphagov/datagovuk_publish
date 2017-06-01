class MakeUuidIndexOnDataset < ActiveRecord::Migration[5.1]
  def change
    add_index :datasets, :uuid
  end
end
