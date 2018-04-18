class RenameLegacyUsersTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :admin_users
    rename_table :users, :legacy_users
  end
end
