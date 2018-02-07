require 'util/linkchecker'

class LinkCheckerWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :link_checker, :retry => 3

  def perform(link_id)
    begin
      link = Link.find(link_id)
      response = RestClient.head(link.url)
      LinkChecker.save_result(link, response)
    rescue RestClient::ExceptionWithResponse
      link.update(broken: true)
      LinkChecker.create_broken_link_task(link)
    end
  end
end
