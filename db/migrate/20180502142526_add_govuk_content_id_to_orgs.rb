class AddGovukContentIdToOrgs < ActiveRecord::Migration[5.1]
  def change
    add_column :organisations, :govuk_content_id, :string
  end
end
