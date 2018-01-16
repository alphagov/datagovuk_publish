class RenameDatafilesToLinks < ActiveRecord::Migration[5.1]
  def change
    rename_table :datafiles, :links
  end
end
