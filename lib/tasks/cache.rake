namespace :cache do

  desc "Clear all caches"
  task :clear => :environment do
    if RedisCache.configured?
      redis = Redis.redis_connection
      redis.keys do |k|
        if k.match(/^#{RedisCache.cache_prefix}/).present?
          redis.del(k)
        end
      end
    else
      puts "Redis Cache is not configured"
    end
  end

end
