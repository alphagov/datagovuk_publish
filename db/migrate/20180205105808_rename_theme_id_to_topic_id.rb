class RenameThemeIdToTopicId < ActiveRecord::Migration[5.1]
  def change
    rename_column :datasets, :theme_id, :topic_id
    rename_column :datasets, :secondary_theme_id, :secondary_topic_id
  end
end
