class RemoveUuids < ActiveRecord::Migration[5.1]
  def change
    change_column :organisations, :uuid, :string
    change_column :datasets, :uuid, :string
    change_column :inspire_datasets, :uuid, :string
    change_column :tasks, :related_object_id, :string
    change_column :datafiles, :uuid, :string
  end
end
