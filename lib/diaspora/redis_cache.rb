#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class RedisCache
  def initialize(user_id, order)
    @user_id = user_id
    @order = order
    self
  end

  # @return [Boolean]
  def cache_exists?
    redis.zcard(set_key) != 0
  end

  def post_ids(time=Time.now, limit=15)
    post_ids = redis.zrevrangebyscore(set_key, time.to_i, "-inf")
    post_ids[0...limit]
  end

  protected
  # @return [Redis]
  def redis
    @redis ||= Redis.new
  end

  # @return [String]
  def set_key
    @set_key ||= "cache_stream_#{@user_id}_#{@order}"
  end
end
