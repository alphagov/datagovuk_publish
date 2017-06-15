class SetPublishedDefaultOnDatasets < ActiveRecord::Migration[5.1]
  def change
    change_column_null :datasets, :published, false, false
    change_column_default :datasets, :published, false
  end
end
