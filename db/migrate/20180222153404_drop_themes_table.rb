class DropThemesTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :themes
  end
end
