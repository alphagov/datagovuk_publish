require 'rails_helper'
require 'active_model'

UrlValidatable = Struct.new(:url) do
  include ActiveModel::Validations

  validates_with UrlValidator
end

RSpec.describe UrlValidator do
  subject { UrlValidatable.new }

  describe 'Url Validator' do
    describe 'Creates validation errors when' do
      before(:each) do
        allow_any_instance_of(UrlValidator).to receive(:valid_path?).and_call_original
      end

      EXPECTED_ERROR_MESSAGE = 'Please enter a valid url'.freeze

      it 'the field is an empty string' do
        subject.url = ''
        subject.validate
        expect(subject.errors[:url]).to include EXPECTED_ERROR_MESSAGE
      end

      it 'the url does not exist' do
        subject.validate
        expect(subject.errors[:url]).to include EXPECTED_ERROR_MESSAGE
      end

      it 'the url does not start with \'http\' or \'https\'' do
        subject.url = 'google.com'
        subject.validate
        expect(subject.errors[:url]).to include EXPECTED_ERROR_MESSAGE
      end

      it 'the host does not exist' do
        url = "http://thishostdoesnotexist.com/data"
        stub_request(:any, url).to_return(status: 404)
        subject.url = url
        subject.validate
        expect(subject.errors[:url]).to include EXPECTED_ERROR_MESSAGE
      end

      it 'the url path does not exist' do
        # allow_any_instance_of(UrlValidator).to receive(:validPath?).and_return(false)
        url = "http://thishostdoesnotexist.com/data"
        stub_request(:any, url).to_return(status: 404)
        subject.url = url
        subject.validate
        expect(subject.errors[:url]).to include EXPECTED_ERROR_MESSAGE
      end
    end

    describe 'Does not create validation error' do
      it 'if url is valid' do
        url = 'http://www.bbc.co.uk/news'
        stub_request(:any, url).to_return(status: 404)
        subject.url = url
        subject.validate
        expect(subject.errors[:url]).to be_empty
      end
    end
  end
end
