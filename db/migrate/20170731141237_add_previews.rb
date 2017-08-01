class AddPreviews < ActiveRecord::Migration[5.1]
  def change
    create_table :previews do |t|
      t.references :datafiles, foreign_key: true
      t.json :content
      t.timestamps
    end
  end
end
