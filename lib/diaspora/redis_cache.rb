#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class RedisCache

  SUPPORTED_CACHES = [:created_at]
  CACHE_LIMIT = 100

  def initialize(user, order_field=:created_at)
    @user = user
    @order_field = order_field.to_s
  end

  # Checks to see if the necessary redis cache variables are set in application.yml
  #
  # @return [Boolean]
  def self.configured?
    AppConfig[:redis_cache].present?
  end

  def self.update_cache_for(user, post, post_was_hidden)
    return unless RedisCache.configured?

    cache = RedisCache.new(user, 'created_at')

    if post_was_hidden
      cache.remove(post.id)
    else
      cache.add(post.created_at.to_i, post.id)
    end
  end

  # @return [Boolean]
  def cache_exists?
    self.redis.exists(set_key)
  end

  # @return [Integer] the cardinality of the redis set
  def size
    redis.zcard(set_key)
  end

  def post_ids(time=Time.now, limit=15)
    post_ids = redis.zrevrangebyscore(set_key, time.to_i, "-inf")
    post_ids[0...limit]
  end

  def ensure_populated!(opts = {})
    self.repopulate!(opts) unless cache_exists?
  end

  def repopulate!(opts = {})
    self.purge!
    self.populate!(opts) && self.trim!
  end

  def purge!
    self.redis.del(set_key)
  end

  def populate!(opts = {})
    # user executes query and gets back hashes
    opts.merge!({
      :type => RedisCache.acceptable_types,
      :limit => CACHE_LIMIT,
      :order => self.order
    })

    sql = @user.visible_shareable_sql(Post, opts)
    hashes = Post.connection.select_all(sql)

    # hashes are inserted into set in a single transaction
    redis.multi do
      hashes.each do |h|
        self.redis.zadd(set_key, h[@order_field].to_i, h["id"])
      end
    end
  end

  def trim!
    self.redis.zremrangebyrank(set_key, 0, -(CACHE_LIMIT+1))
  end

  # @param order [Symbol, String]
  # @return [Boolean]
  def self.supported_order?(order)
    SUPPORTED_CACHES.include?(order.to_sym)
  end

  def order
    "#{@order_field} DESC"
  end

  def add(score, id)
    return unless self.cache_exists?
    self.redis.zadd(set_key, score.to_i, id)
    self.trim!
  end

  def remove(id)
    return unless self.cache_exists?
    self.redis.zrem(set_key, id)
  end

  # exposing the need to tie cache to a stream
  # @return [Array<String>] Acceptable Post types for the given cache
  def self.acceptable_types
    Stream::Base::TYPES_OF_POST_IN_STREAM
  end

  # Instantiate a redis connection
  #
  # @return [Redis]
  def self.redis_connection
    Redis.new(:host => RedisCache.redis_host, :port => RedisCache.redis_port)
  end

  protected
  # @see .redis_connection
  # @return [Redis]
  def redis
    @redis ||= RedisCache.redis_connection
  end

  def self.redis_host
    (AppConfig[:redis_location].blank?) ? nil : AppConfig[:redis_location]
  end

  def self.redis_port
    (AppConfig[:redis_port].blank?) ? nil : AppConfig[:redis_port]
  end

  # @return [String]
  def self.cache_prefix
    "cache_stream"
  end

  # @return [String]
  def set_key
    @set_key ||= "#{RedisCache.cache_prefix}_#{@user.id}_#{@order_field}"
  end
end
