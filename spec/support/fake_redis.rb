module Diaspora::WebSocket
  def self.redis
    FakeRedis.new
  end
end

class FakeRedis
  def rpop(*args)
    true
  end
  def llen(*args)
    true
  end
  def lpush(*args)
    true
  end
  def sismember(*args)
    false
  end
end
