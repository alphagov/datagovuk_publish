class AddActiveToOrganisations < ActiveRecord::Migration[5.1]
  def change
    add_column :organisations, :active, :boolean, default: true
  end
end
