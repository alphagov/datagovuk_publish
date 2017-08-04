require 'rails_helper'

describe "Previews API" do
  before(:each) do
    org = Organisation.new
    org.name = 'land-registry'
    org.title = 'Land Registry'
    org.save!()

    ds = Dataset.new
    ds.name = ds.title = ds.summary = 'preview-test'
    ds.organisation = org
    ds.frequency = "never"
    ds.save!()

    @link = Link.new
    @link.name = "test"
    @link.url = "http://127.0.0.1/fake"
    @link.format = "csv"
    @link.dataset = ds
    @link.save!()

    @noprev = Link.new
    @noprev.name = "test"
    @noprev.url = "http://127.0.0.1/fake2"
    @noprev.format = "csv"
    @noprev.dataset = ds
    @noprev.save!()

    @prev = Preview.new
    @prev.link = @link
    @prev.content = {type: "csv", body: '[["test"]]'}
    @prev.save!()
  end

  it 'sends a preview' do
    visit "/api/previews/#{@link.id}"
    json = JSON.parse(page.body)
    expect(page.status_code).to be 200
    expect(json["content"]["type"]).to eq("csv")
  end

  it 'sends no preview if does not exist' do
    visit "/api/previews/#{@noprev.id}"
    json = JSON.parse(page.body)
    expect(page.status_code).to be 200
    expect(json.size).to eq(0)
  end

  it 'sends nothing if file id not found' do
    visit '/api/previews/10101010101010101'
    expect(page.status_code).to be 404
  end

end
