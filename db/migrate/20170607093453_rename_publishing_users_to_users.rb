class RenamePublishingUsersToUsers < ActiveRecord::Migration[5.1]
  def change
    rename_table :publishing_users, :users
    rename_table :organisations_publishing_users, :organisations_users
  end
end
