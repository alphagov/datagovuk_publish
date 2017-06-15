class AddNameToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :name, :string, null: false
  end
end
