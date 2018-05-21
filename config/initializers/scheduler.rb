scheduler = Rufus::Scheduler.singleton

scheduler.every '1m' do
  ModelMetricsWorker.new.perform
end
