class RemoveMonthYearFromDatafiles < ActiveRecord::Migration[5.1]
  def change
    remove_column :datafiles, :year, :integer
    remove_column :datafiles, :month, :integer
  end
end
