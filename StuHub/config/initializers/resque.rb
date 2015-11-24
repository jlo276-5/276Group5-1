uri = URI.parse ENV["REDISCLOUD_URL"] || ENV["OPENREDIS_URL"] || ENV["REDISGREEN_URL"] || ENV["REDISTOGO_URL"] || ENV["REDIS_URL"]
Resque.redis = Redis.new(host:uri.host, port:uri.port, password:uri.password)
