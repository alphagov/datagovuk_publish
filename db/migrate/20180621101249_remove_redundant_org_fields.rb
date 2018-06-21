class RemoveRedundantOrgFields < ActiveRecord::Migration[5.1]
  def change
    remove_column :organisations, :description
    remove_column :organisations, :abbreviation
    remove_column :organisations, :replace_by
    remove_column :organisations, :contact_phone
    remove_column :organisations, :foi_phone
    remove_column :organisations, :organisation_user_id
    remove_column :organisations, :ancestry
    remove_column :organisations, :org_type
  end
end
