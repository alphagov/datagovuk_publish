require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if ENV["VCAP_SERVICES"]
  services = JSON.parse(ENV["VCAP_SERVICES"])

  if services.keys.include?('user-provided')
    # Extract UPSes and pull out secrets configs
    user_provided_services = services['user-provided'].select { |s| s['name'].include?('secrets') }
    credentials = user_provided_services.map { |s| s['credentials'] }.reduce(:merge)

    # Take each credential and assign to ENV
    credentials.each do |k, v|
      # Don't overwrite existing env vars
      ENV[k.upcase] ||= v
    end
  end
end

module PublishDataBeta
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Don't add a div with field_with_errors class
    # as it breaks the gov.uk elements error styling
    config.action_view.field_error_proc = Proc.new { |html_tag, _|
      html_tag
    }

    # TODO: replace the origins wildcard to accept requets from find only?
    # https://github.com/cyu/rack-cors#origin
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get]
      end
    end
    config.autoload_paths += %W(#{config.root}/app/workers)
    config.eager_load_paths += %W(#{config.root}/app/presenters)

    config.elasticsearch = config_for(:elasticsearch)

    config.filter_parameters << :password
    config.filter_parameters << :password_confirmation

    Raven.configure do |config|
      if ENV['SENTRY_DSN']
        config.dsn = ENV['SENTRY_DSN']
      end

      config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    end
  end
end
