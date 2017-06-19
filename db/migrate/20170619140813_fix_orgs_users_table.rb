class FixOrgsUsersTable < ActiveRecord::Migration[5.1]
  def change
    rename_column :organisations_users, :publishing_user_id, :user_id
  end
end
