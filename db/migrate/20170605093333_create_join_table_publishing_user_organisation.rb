class CreateJoinTablePublishingUserOrganisation < ActiveRecord::Migration[5.1]
  def change
    create_join_table :organisations, :publishing_users do |t|
      # t.index [:publishing_user_id, :organisation_id]
      # t.index [:organisation_id, :publishing_user_id]
    end
  end
end
