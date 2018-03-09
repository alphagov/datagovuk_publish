REDIS_CONFIG = Rails.application.config_for(:redis).symbolize_keys

Sidekiq.configure_server { |config| config.redis = REDIS_CONFIG }
Sidekiq.configure_client { |config| config.redis = REDIS_CONFIG }
