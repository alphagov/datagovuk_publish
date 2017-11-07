require 'rails_helper'

describe Legacy::Datafile do
  describe '#update' do
    it "sends an update request to legacy when it is published" do
      stub_request(:post, legacy_datafile_update_endpoint).to_return(status: 200)

      link = FactoryGirl.create(:link)
      legacy_datafile = Legacy::Datafile.new(link)

      FactoryGirl.create(:dataset, links: [link])

      legacy_datafile.update

      expect(WebMock)
        .to have_requested(:post, legacy_datafile_update_endpoint)
        .with(body: legacy_datafile.payload)
    end
  end
end
