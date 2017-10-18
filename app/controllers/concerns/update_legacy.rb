module UpdateLegacy
  include ActiveSupport::Concern

  def update_legacy
    LegacySyncWorker.perform_async(@dataset.id)
  end
  
end
