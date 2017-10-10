require 'rails_helper'
require './lib/sync/legacy_datasets'

describe SyncController, type: :controller do
  it 'invokes the sync legacy dataset rake task' do
    allow_any_instance_of(LegacyDataSync).to receive(:run).and_return true
    post :legacy
    assert_response :success
  end
end
