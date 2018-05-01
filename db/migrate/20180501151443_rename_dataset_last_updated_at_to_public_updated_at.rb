class RenameDatasetLastUpdatedAtToPublicUpdatedAt < ActiveRecord::Migration[5.1]
  def change
    rename_column :datasets, :last_updated_at, :public_updated_at
  end
end
