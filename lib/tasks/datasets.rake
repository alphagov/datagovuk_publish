namespace :datasets do
  desc "Migrate dataset status from published boolean field to status enum field"
  task migrate_status: :environment do
    published_datasets = Dataset.where(published: true)
    draft_datasets = Dataset.where(published: false)

    puts "Going to update #{published_datasets.count} published datasets and #{draft_datasets.count} draft datasets."

    ActiveRecord::Base.transaction do
      # :update_all constructs a single SQL UPDATE statement and sends it straight to the database.
      # It does not trigger ActiveRecord callbacks or validations, and updated_at is not updated.
      published_datasets.update_all(status: "published")
    end

    puts "Done updating published datasets!"

    ActiveRecord::Base.transaction do
      draft_datasets.update_all(status: "draft")
    end

    puts "Done updating draft datasets!"

    puts " All done now!"
  end
end
