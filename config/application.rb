require_relative "boot"

require "rails"
# Pick the frameworks you want:
# require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if ENV["VCAP_SERVICES"]
  services = JSON.parse(ENV["VCAP_SERVICES"])

  if services.key?("user-provided")
    # Extract UPSes and pull out secrets configs
    user_provided_services = services["user-provided"].select { |s| s["name"].include?("secrets") }
    credentials = user_provided_services.map { |s| s["credentials"] }.reduce(:merge)

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
    config.load_defaults 6.0
    config.generators.system_tests = nil

    # Don't add a div with field_with_errors class
    # as it breaks the gov.uk elements error styling
    config.action_view.field_error_proc = proc { |html_tag, _|
      html_tag
    }

    config.autoload_paths += [Rails.root.join("app/workers")]
    config.autoload_paths += [Rails.root.join("lib/validators")]
    config.autoload_paths += [Rails.root.join("lib/ckan")]

    config.elasticsearch = config_for(:elasticsearch)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
