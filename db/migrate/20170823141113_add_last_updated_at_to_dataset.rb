class AddLastUpdatedAtToDataset < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :last_updated_at, :datetime
  end
end
