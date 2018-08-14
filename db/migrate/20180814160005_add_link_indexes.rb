class AddLinkIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :links, :type
    add_index :links, :dataset_id
  end
end
