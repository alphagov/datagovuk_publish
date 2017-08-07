class RemoveUnusedExtensions < ActiveRecord::Migration[5.1]
  def change
    disable_extension "plpgsql"
    disable_extension "uuid-ossp"
  end
end
