class RemoveLastPublishedAtFromDataset < ActiveRecord::Migration[5.1]
  def change
    remove_column :datasets, :last_published_at
  end
end
