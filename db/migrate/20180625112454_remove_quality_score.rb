class RemoveQualityScore < ActiveRecord::Migration[5.1]
  def change
    drop_table :quality_scores
  end
end
