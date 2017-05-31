class CreateDatafiles < ActiveRecord::Migration[5.1]
  def change
    create_table :datafiles do |t|
      t.string :name
      t.text :url
      t.string :format
      t.integer :size
      t.integer :dataset_id
      t.date :start_date
      t.date :end_date
      t.integer :month
      t.integer :year
      t.integer :quarter
      t.boolean :broken
      t.datetime :last_check
      t.boolean :documentation

      t.timestamps
    end
  end
end
