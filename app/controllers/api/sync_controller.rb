class API::SyncController < ApplicationController
  def beta
    BetaUpdateWorker.perform_async
    head :ok
  end
end
