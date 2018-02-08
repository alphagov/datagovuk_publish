class AddTopicIdToDataset < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :topic_id, :integer
    add_column :datasets, :secondary_topic_id, :integer
  end
end
