require 'rake'

class SyncController < ApplicationController
  def legacy
    LegacyDataSync.new.run
    head :ok
  end
end
