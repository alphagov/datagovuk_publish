class AddOrganisationType < ActiveRecord::Migration[5.1]
  def change
    add_column :organisations, :org_type, :string
  end
end
