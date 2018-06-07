class RemoveUnusedLinkFields < ActiveRecord::Migration[5.1]
  def change
    remove_column :links, :size
    remove_column :links, :last_check
    remove_column :links, :documentation
    remove_column :links, :short_id
  end
end
