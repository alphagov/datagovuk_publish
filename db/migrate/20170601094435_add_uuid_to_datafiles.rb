class AddUuidToDatafiles < ActiveRecord::Migration[5.1]
  def change
    add_column :datafiles, :uuid, :uuid
    add_index :datafiles, :uuid
  end
end
