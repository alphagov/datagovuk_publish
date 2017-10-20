module UpdateLegacy
  include ActiveSupport::Concern

  def update_legacy
    PublishToLegacyUpdateWorker.perform_async(@dataset.id)
  end

end
