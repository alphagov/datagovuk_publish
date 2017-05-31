class CreateOrganisations < ActiveRecord::Migration[5.1]
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :title
      t.text :description
      t.string :abbreviation
      t.string :replace_by
      t.string :contact_email
      t.string :contact_phone
      t.string :contact_name
      t.string :foi_email
      t.string :foi_phone
      t.string :foi_name
      t.string :foi_web
      t.string :category
      t.integer :organisation_user_id

      t.timestamps
    end
  end
end
