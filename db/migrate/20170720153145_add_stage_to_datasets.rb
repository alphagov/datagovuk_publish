class AddStageToDatasets < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :stage, :string
  end
end
