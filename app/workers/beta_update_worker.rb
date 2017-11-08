require 'rake'
PublishDataBeta::Application.load_tasks

class BetaUpdateWorker
  include Sidekiq::Worker

  def perform
    Rake::Task['sync:beta'].invoke
  end
end
