class DropOrganisationUsers < ActiveRecord::Migration[5.1]
  def change
    drop_table :organisations_users
  end
end
