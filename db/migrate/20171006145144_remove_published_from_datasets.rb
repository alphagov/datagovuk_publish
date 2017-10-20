class RemovePublishedFromDatasets < ActiveRecord::Migration[5.1]
  def change
    remove_column :datasets, :published, :boolean
  end
end
