class RemoveAdminUsers < ActiveRecord::Migration[5.1]
  def change
    drop_table :admin_users
  end
end
