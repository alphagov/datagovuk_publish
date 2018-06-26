class AddInspireAccessConstraintField < ActiveRecord::Migration[5.1]
  def change
    add_column :inspire_datasets, :access_constraints, :text
  end
end
