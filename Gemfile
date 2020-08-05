source "https://rubygems.org"

ruby IO.read(".ruby-version").strip

gem "rails", "6.0.3.2"

gem "audited"
gem "cancancan"
gem "elasticsearch", "~> 5.0" # gem's major must match db's
gem "elasticsearch-model"
gem "elasticsearch-rails"
gem "gds-sso"
gem "govuk_app_config"
gem "govuk_elements_rails"
gem "govuk_sidekiq"
gem "govuk_template"
gem "iconv"
gem "jbuilder"
gem "jquery-rails"
gem "kaminari", "< 1.2" # do not upgrade this unless elasticsearch is also upgraded
gem "lograge"
gem "logstash-event"
gem "mime-types"
gem "pg"
gem "plek"
gem "puma"
gem "rest-client"
gem "rubyzip"
gem "sass-rails"
gem "sentry-raven"
gem "sidekiq-limit_fetch"
gem "sidekiq-scheduler"
gem "turbolinks"
gem "uglifier"
gem "whois-parser"

group :development, :test do
  gem "brakeman"
  gem "byebug"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
  gem "rspec"
  gem "rspec-rails"
  gem "rubocop-govuk"
end

group :development do
  gem "pry-rails"
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen"
end

group :test do
  gem "capybara"
  # Gem codeclimate-test-reporter pinned to ~> 1.0.9 because simplecov >= 0.13
  # causes it to be downgraded to 1.0.7, which doesn't work.
  #
  # Also note that the gem was deprecated in favour of a new tool:
  # https://docs.codeclimate.com/docs/configuring-test-coverage
  gem "codeclimate-test-reporter", "~> 1.0.9"
  gem "database_cleaner"
  gem "simplecov"
  gem "webmock"
end
