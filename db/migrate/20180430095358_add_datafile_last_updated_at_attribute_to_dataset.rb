class AddDatafileLastUpdatedAtAttributeToDataset < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :datafile_last_updated_at, :datetime
  end
end
