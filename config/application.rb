require_relative 'boot'

require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"

if defined?(Bundler)
  # If you want your assets lazily compiled in production, use this line
  Bundler.require(*Rails.groups)
  Bundler.require(:default, :assets, Rails.env)
end

if ENV["VCAP_SERVICES"]
  services = JSON.parse(ENV["VCAP_SERVICES"])

  if services.key?('user-provided')
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
    config.generators.system_tests = nil

    # Don't add a div with field_with_errors class
    # as it breaks the gov.uk elements error styling
    config.action_view.field_error_proc = Proc.new { |html_tag, _|
      html_tag
    }

    config.autoload_paths += [Rails.root.join("app", "workers")]
    config.autoload_paths += [Rails.root.join("lib", "validators")]
    config.autoload_paths += [Rails.root.join("lib", "ckan")]

    config.elasticsearch = config_for(:elasticsearch)
  end
end
