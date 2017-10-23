require 'rest-client'

class PublishToLegacyUpdateDatafilesWorker
  include Sidekiq::Worker

  def perform(id)
    datafile = Datafile.find(id)
    Legacy::Datafile.new(datafile).update
  end

end
