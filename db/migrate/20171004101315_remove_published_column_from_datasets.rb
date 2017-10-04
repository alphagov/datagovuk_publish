class RemovePublishedColumnFromDatasets < ActiveRecord::Migration[5.1]
  def change
    remove_column :datasets, :published
  end
end
