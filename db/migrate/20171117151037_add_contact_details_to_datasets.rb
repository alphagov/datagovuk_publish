class AddContactDetailsToDatasets < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :foi_name, :string
    add_column :datasets, :foi_phone, :string
    add_column :datasets, :foi_email, :string
  end
end
