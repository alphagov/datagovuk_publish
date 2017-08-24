class FixPreviewDatafilesColumnName < ActiveRecord::Migration[5.1]
  def change
    if column_exists?(:previews, :datafile_id)
      rename_column :previews, :datafile_id, :datafiles_id
    end
  end
end
