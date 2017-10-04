class AddEnumToDatasets < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :status, :integer, default: 0
  end
end
