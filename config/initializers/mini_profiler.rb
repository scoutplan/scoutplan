Rack::MiniProfiler.config.storage_options = { url: ENV.fetch("REDIS_URL") }
Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
