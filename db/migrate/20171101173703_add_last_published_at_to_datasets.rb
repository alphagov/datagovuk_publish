class AddLastPublishedAtToDatasets < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :last_published_at, :datetime
  end
end
