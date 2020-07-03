# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

tasks = %i[spec brakeman]
if Rails.env.development? || Rails.env.test?
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
  tasks = %i[spec brakeman rubocop]
end

Rails.application.load_tasks

task default: tasks
