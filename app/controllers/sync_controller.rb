class SyncController < ApplicationController
  def legacy
    call_rake('sync:daily')
    msg = { status: 200, body: 'Syncing legacy datasets' }
    render json: msg
  end
end
