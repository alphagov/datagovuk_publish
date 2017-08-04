class AddThemeFieldToDataset < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :theme_id, :integer
    add_column :datasets, :secondary_theme_id, :integer
  end
end
