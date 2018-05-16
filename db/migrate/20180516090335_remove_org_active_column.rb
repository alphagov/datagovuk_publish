class RemoveOrgActiveColumn < ActiveRecord::Migration[5.1]
  def change
    remove_column :organisations, :active
  end
end
