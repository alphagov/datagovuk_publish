namespace :orgs do
  desc "Mark replaced orgs as inactive"
  task :mark_replaced_as_inactive do
    Organisation.all.each do |o|
      if o.replace_by && o.replace_by != '[]' && o.active
        o.active = false
        o.save!

        puts "Marked #{o.title} as inactive"
      end
    end

    puts "Done. There are #{Organisation.where(active: false).length} inactive organisations."
  end
end
