require 'rake'
PublishDataBeta::Application.load_tasks

class LegacyToBetaDatasetSyncWorker
  include Sidekiq::Worker

  def perform
    Rake::Task['sync:daily'].invoke
  end
end
