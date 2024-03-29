source "https://rubygems.org"

gem "rails", "6.1.6.1"

gem "audited"
gem "cancancan"
gem "elasticsearch", "~> 7.9.0" # gem's major must match db's
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
gem "kaminari"
gem "lograge"
gem "logstash-event"
gem "matrix"
gem "mime-types"
gem "net-imap", require: false
gem "net-pop", require: false
gem "net-smtp"
gem "pg"
gem "plek"
gem "rest-client"
gem "rubyzip"
gem "sass-rails"
gem "sentry-sidekiq"
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
  gem "database_cleaner"
  gem "simplecov", "< 0.23" # see https://github.com/codeclimate/test-reporter/issues/413
  gem "webmock"
end
