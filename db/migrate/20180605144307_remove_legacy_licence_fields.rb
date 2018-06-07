class RemoveLegacyLicenceFields < ActiveRecord::Migration[5.1]
  def change
    remove_column :datasets, :licence
    remove_column :datasets, :licence_other
  end
end
