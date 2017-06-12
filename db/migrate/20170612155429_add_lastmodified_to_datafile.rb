class AddLastmodifiedToDatafile < ActiveRecord::Migration[5.1]
  def change
    add_column :datafiles, :last_modified, :datetime
  end
end
