class PreviewGenerationWorker
  include Sidekiq::Worker

  def perform(link_id)
    link = Link.find(link_id)
    link.generate_preview
  end
end
