class RemoveThemeIdFromDataset < ActiveRecord::Migration[5.1]
  def change
    remove_column :datasets, :theme_id
    remove_column :datasets, :secondary_theme_id
  end
end
