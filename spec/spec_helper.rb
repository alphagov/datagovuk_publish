ENV["RAILS_ENV"] = 'test'

require "simplecov"
require "factory_girl_rails"
require "database_cleaner"
require "sidekiq/testing"
require 'webmock/rspec'

include WebMock::API
WebMock.disable_net_connect!(allow_localhost: true)
WebMock.disable_net_connect!(allow: "#{ENV['ES_HOST']}:9200")

Sidekiq::Testing.inline!

SimpleCov.start do
  add_filter "/app/admin/"
  add_filter "/spec/"
end

RSpec.configure do |config|
  config.before(:each) do
    delete_index
    create_index
  end

  config.after(:each) do
    delete_index
  end

  config.include FactoryGirl::Syntax::Methods
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    allow_any_instance_of(UrlValidator).to receive(:validPath?).and_return(true)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end

def mappings
  DatasetsIndexerService::INDEX_MAPPING
end

def delete_index
  if Rails.env == "test"
    begin
      ELASTIC.indices.delete index: "datasets-test"
    rescue
      Rails.logger.debug("No test search index to delete")
    end
  end
end

def create_index
  if Rails.env == "test"
    begin
      Rails.logger.info("Creating datasets-test index")

      ELASTIC.indices.create(
        index: "datasets-test",
        body: {
          mappings: mappings
        }
      )
    rescue
      Rails.logger.debug("Could not create datasets-test index")
    end
  end
end
