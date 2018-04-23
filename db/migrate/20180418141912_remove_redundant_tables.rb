class RemoveRedundantTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :quality_scores
    drop_table :organisation_statistics
  end
end
