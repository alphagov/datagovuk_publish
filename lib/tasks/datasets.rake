namespace :datasets do
  desc "Migrate dataset status from published boolean field to status enum field"
  task migrate_status: :environment do
    puts "Starting dataset status migration ..."

    draft = Dataset.statuses[:draft] # 0
    published = Dataset.statuses[:published] # 1

    update_drafts_query = <<~SQL
      UPDATE datasets SET status = #{draft} WHERE published = 'false';
    SQL

    update_published_query = <<~SQL
      UPDATE datasets SET status = #{published} WHERE published = 'true';
    SQL

    connection = ActiveRecord::Base.connection

    connection.exec_query(update_drafts_query)
    connection.exec_query(update_published_query)

    puts "All done now!"
  end
end
