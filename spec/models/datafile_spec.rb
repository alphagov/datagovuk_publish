require 'rails_helper'

describe Datafile do
  describe '#update_legacy' do
    it "sends an update request to legacy when it is updated" do
      url = "#{ENV['LEGACY_HOST']}#{Legacy::Datafile::ENDPOINTS[:patch]}"
      stub_request(:post, url).to_return(status: 200)

      link = FactoryGirl.create(:link)
      legacy_datafile = Legacy::Datafile.new(link)

      FactoryGirl.create(:dataset, links: [link])

      link.update_legacy

      expect(WebMock)
        .to have_requested(:post, url)
        .with(body: legacy_datafile.payload)
    end
  end
end
