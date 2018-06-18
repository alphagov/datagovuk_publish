class RemoveRedundantDatasetColumns < ActiveRecord::Migration[5.1]
  def change
    remove_column :datasets, :secondary_topic_id
    remove_column :datasets, :dataset_type
    remove_column :datasets, :contact_phone
    remove_column :datasets, :foi_phone
    remove_column :datasets, :published_date
    remove_column :datasets, :last_updated_at
  end
end
