require 'rake'
require './lib/sync/legacy_datasets'

class SyncController < ApplicationController
  def legacy
    LegacyDataSync.new.run
    head :ok
  end
end
