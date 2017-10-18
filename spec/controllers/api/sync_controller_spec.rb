require 'rails_helper'

describe API::SyncController, type: :controller do
  it 'invokes the sync legacy dataset rake task' do
    allow_any_instance_of(LegacyToBetaDatasetSyncWorker).to receive(:perform).and_return true
    get :legacy
    assert_response :success
  end
end
