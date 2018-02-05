class RenameThemesToTopics < ActiveRecord::Migration[5.1]
  def change
    rename_table :themes, :topics
  end
end
