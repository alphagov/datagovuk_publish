require "rails_helper"
require "active_model"

UrlValidatable = Struct.new(:url) do
  include ActiveModel::Validations

  validates_with UrlValidator
end

RSpec.describe UrlValidator do
  subject { UrlValidatable.new }

  describe "Url Validator" do
    describe "Creates validation errors when" do
      before(:each) do
        allow_any_instance_of(UrlValidator).to receive(:valid_path?).and_call_original
      end

      expected_error_message = "Please enter a valid url".freeze

      it "the field is an empty string" do
        subject.url = ""
        subject.validate
        expect(subject.errors[:url]).to include expected_error_message
      end

      it "the url does not exist" do
        subject.validate
        expect(subject.errors[:url]).to include expected_error_message
      end

      it "the url does not start with 'http' or 'https' or 'ftp'" do
        subject.url = "google.com"
        subject.validate
        expect(subject.errors[:url]).to include expected_error_message
      end

      it "the url path does not exist" do
        url = "http://thispathdoesnotexist.com/data"
        stub_request(:any, url).to_return(status: 404)
        subject.url = url
        subject.validate
        expect(subject.errors[:url]).to include expected_error_message
      end

      it "the host does not exists" do
        # allow_any_instance_of(UrlValidator).to receive(:validPath?).and_return(false)
        url = "http://thishostdoesnotexist.com/data"
        stub_request(:any, url).to_raise(SocketError)
        subject.url = url
        subject.validate
        expect(subject.errors[:url]).to include expected_error_message
      end

      it "the host refuses the connection" do
        # allow_any_instance_of(UrlValidator).to receive(:validPath?).and_return(false)
        url = "http://flakey.website/data"
        stub_request(:any, url).to_raise(Errno::ECONNREFUSED)
        subject.url = url
        subject.validate
        expect(subject.errors[:url]).to include expected_error_message
      end
    end

    describe "Knows whether a URL is encoded or not" do
      it "can tell a string is not encoded" do
        real_validator = UrlValidator.new
        source = "http://test.com/encoded url"
        expect(real_validator.encoded?(source)).to be_falsey
      end

      it "can tell a string is encoded" do
        real_validator = UrlValidator.new
        source = "http://test.com/encoded%20url"
        expect(real_validator.encoded?(source)).to be_truthy
      end
    end

    describe "Does not create validation error" do
      it "if url is valid" do
        url = "http://www.bbc.co.uk/news"
        stub_request(:any, url).to_return(status: 404)
        subject.url = url
        subject.validate
        expect(subject.errors[:url]).to be_empty
      end

      it "if it has spaces in the URL" do
        url = "http://thishostdoesnotexist.com/data/file with spaces.csv"
        stub_request(:any, url).to_return(status: 200)
        subject.url = url
        subject.validate
        expect(subject.errors[:url]).to be_empty
      end
    end
  end
end
