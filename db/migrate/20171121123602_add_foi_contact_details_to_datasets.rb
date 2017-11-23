class AddFoiContactDetailsToDatasets < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :contact_name, :string
    add_column :datasets, :contact_email, :string
    add_column :datasets, :contact_phone, :string

    add_column :datasets, :foi_name, :string
    add_column :datasets, :foi_email, :string
    add_column :datasets, :foi_phone, :string
    add_column :datasets, :foi_web, :string
  end
end
