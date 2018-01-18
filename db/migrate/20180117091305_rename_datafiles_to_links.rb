class RenameDatafilesToLinks < ActiveRecord::Migration[5.1]
  def change
    remove_index :datafiles, :uuid
    rename_table :datafiles, :links
    add_index :links, :uuid
  end
end
