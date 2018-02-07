class LinkCheckerWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :link_checker, :retry => 3

  def perform(link_id)
    link = Link.find(link_id)
    LinkCheckerService.new(link).run
  end
end
