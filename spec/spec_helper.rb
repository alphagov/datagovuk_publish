ENV["RAILS_ENV"] = 'test'

require "simplecov"
require "factory_girl_rails"
require "database_cleaner"
require "govuk_sidekiq/testing"
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

Sidekiq::Logging.logger = Rails.logger
Sidekiq::Testing.inline!

SimpleCov.start unless ENV["NO_RCOV"]

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include WebMock::API

  config.order = :random

  config.before(:each) do
    IndexDeletionService.new(index_alias: "datasets-test",
                             client: Dataset.__elasticsearch__.client,
                             logger: Rails.logger,
                             indices_to_keep: 0).run
  end

  config.before(:each) do
    allow_any_instance_of(UrlValidator).to receive(:valid_path?).and_return(true)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end
