class API::SyncController < ApplicationController
  skip_before_action :authenticate_user!

  def beta
    BetaUpdateWorker.perform_async
    head :ok
  end
end
