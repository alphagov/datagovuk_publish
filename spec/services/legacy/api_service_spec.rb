require 'rails_helper'

describe Legacy::APIService do
  let(:api_service) { Legacy::APIService.new }

  before(:each) do
    dataset = %{
      {"result": #{File.read('spec/fixtures/legacy_dataset.json')}}
    }
    organisation = %{
      {"result": #{File.read('spec/fixtures/legacy_organisation.json')}}
    }

    stub_request(:get, "https://test.data.gov.uk/api/3/action/package_show?id=a_dataset").
      to_return(status: 200, body: dataset)
    stub_request(:get, 'https://test.data.gov.uk/api/3/action/publisher_show?id=a_publisher').
      to_return(status: 200, body: organisation)
    stub_request(:get, "https://test.data.gov.uk/api/3/action/package_show?id=fake").
      to_return(status: 404)
  end

  describe "can retrieve valid data" do
    it "can get dataset info " do
      result = api_service.dataset_show('a_dataset')
      expect(result['name']).to eql('local_directgov_services')
    end

    it "can get publisher info " do
      result = api_service.publisher_show('a_publisher')
      expect(result['name']).to eql('2gether-nhs-foundation-trust')
    end
  end

  describe "can handle missing resources" do
    it "does not explode with missing publisher or dataset" do
      result = api_service.dataset_show('fake')
      expect(result).to be_nil
    end
  end
end
