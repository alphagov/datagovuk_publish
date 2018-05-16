class DropOrganisationStatistics < ActiveRecord::Migration[5.1]
  def change
    drop_table :organisation_statistics
  end
end
