# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
require 'sidekiq/prometheus/exporter'
require 'sidekiq/web'

Sidekiq::Web.register(Sidekiq::Prometheus::Exporter)

run Rails.application
