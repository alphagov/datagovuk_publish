require 'rails_helper'

describe Datasets::LinksController do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in(user)
  end

  it "updates legacy when a datafile is updated" do
    link = FactoryGirl.create(:link)
    dataset = FactoryGirl.create(:dataset, links: [link])
    url = "#{ENV['LEGACY_HOST']}#{Legacy::Datafile::ENDPOINTS[:patch]}"

    stub_request(:post, url).to_return(status: 200)

    patch :update, params: { uuid: dataset.uuid, name: dataset.name, id: link.id, link: { name: "New Data Link Name" } }

    legacy_datafile = Legacy::Datafile.new(link.reload)

    expect(WebMock)
      .to have_requested(:post, url)
      .with(body: legacy_datafile.payload)
  end
end
