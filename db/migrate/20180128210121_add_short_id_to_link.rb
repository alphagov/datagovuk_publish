class AddShortIdToLink < ActiveRecord::Migration[5.1]
  def change
    add_column :links, :short_id, :string, unique: true
    add_index :links, :short_id, unique: true
  end
end
