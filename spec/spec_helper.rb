ENV["RAILS_ENV"] = 'test'

require "simplecov"
require "factory_girl_rails"
require "database_cleaner"
require "govuk_sidekiq/testing"
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

Sidekiq::Logging.logger = Rails.logger
Sidekiq::Testing.inline!

SimpleCov.start

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include WebMock::API

  config.order = :random

  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end
