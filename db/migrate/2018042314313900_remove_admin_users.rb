class RemoveAdminUsers < ActiveRecord::Migration[5.1]
  def change
    drop_table :admin_users, if_exists: true
  end
end
