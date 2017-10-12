class SyncController < ApplicationController
  def legacy
    LegacyToBetaDatasetSyncWorker.perform_async
    head :ok
  end
end
