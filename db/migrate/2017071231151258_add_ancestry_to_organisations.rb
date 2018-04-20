class AddAncestryToOrganisations < ActiveRecord::Migration[5.1]
  def change
    add_column :organisations, :ancestry, :string
    add_index :organisations, :ancestry
  end
end
