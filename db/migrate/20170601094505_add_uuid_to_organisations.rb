class AddUuidToOrganisations < ActiveRecord::Migration[5.1]
  def change
    add_column :organisations, :uuid, :uuid
    add_index :organisations, :uuid
  end
end
