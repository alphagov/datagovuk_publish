namespace :sync do
  desc 'Sync modified or new datasets from legacy to beta'
  task beta: :environment do |_, args|
    worker = BetaUpdateWorker.new
    worker.logger = Rails.logger
    worker.perform
  end
end
