module Diaspora::WebSocket
  def self.redis
    MockRedis.new
  end
end

class RedisCache
  def self.redis_connection
    MockRedis.new
  end
end
