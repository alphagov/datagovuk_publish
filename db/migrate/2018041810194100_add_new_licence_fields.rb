class AddNewLicenceFields < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :licence_code, :string
    add_column :datasets, :licence_title, :string
    add_column :datasets, :licence_url, :text
    add_column :datasets, :licence_custom, :text
  end
end
