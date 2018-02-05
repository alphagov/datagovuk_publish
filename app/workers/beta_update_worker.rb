require 'rake'
PublishDataBeta::Application.load_tasks

class BetaUpdateWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :indexer, :retry => false

  def perform
    Rake::Task['sync:beta'].invoke
  end
end
