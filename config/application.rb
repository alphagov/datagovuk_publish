require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "dotenv/load" if Rails.env.development? || Rails.env.test?
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

  end
end
