class AddMetadataLastUpdatedAtToDataset < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :metadata_last_updated_at, :datetime
  end
end
