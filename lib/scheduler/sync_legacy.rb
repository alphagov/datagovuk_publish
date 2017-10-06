require 'rufus-scheduler'
require 'rake'

scheduler = Rufus::Scheduler.new

scheduler.cron('0 7,19 * * *') do
  puts 'Syncing legacy datasets ...'
  system('rake sync:daily RAILS_ENV=Rails.env')
end

scheduler.join
