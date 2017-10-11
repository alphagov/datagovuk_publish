REDIS_CONFIG = Rails.application.config_for(:redis)

Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{REDIS_CONFIG[:host]}:#{REDIS_CONFIG[:port]}/12",
    password: REDIS_CONFIG[:password]
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{REDIS_CONFIG[:host]}:#{REDIS_CONFIG[:port]}/12",
    password: REDIS_CONFIG[:password]
  }
end
