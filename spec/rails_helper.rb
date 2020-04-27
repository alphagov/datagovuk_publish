ENV["RAILS_ENV"] = "test"

require "simplecov"
require "govuk_sidekiq/testing"
require "webmock/rspec"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

Sidekiq::Logging.logger = Rails.logger
Sidekiq::Testing.inline!
SimpleCov.start
ActiveRecord::Migration.maintain_test_schema!

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: Rails.configuration.elasticsearch["host"],
)

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include WebMock::API
  config.include LogInControllerHelper, type: :controller
  config.include LogInFeatureHelper, type: :feature
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
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

  config.before(:each) do
    stub_request(:post, /sentry.io/).
      to_return(status: 200, body: "stubbed response", headers: {})
  end
end
