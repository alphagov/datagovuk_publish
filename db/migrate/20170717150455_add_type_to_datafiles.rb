class AddTypeToDatafiles < ActiveRecord::Migration[5.1]
  def change
    add_column :datafiles, :type, :string
  end
end
