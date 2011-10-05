namespace :cache do

  desc "Clear all caches"
  task :clear => :environment do
    if RedisCache.configured?
      redis = RedisCache.redis_connection
      puts "Clearing Cache..."
      redis.keys do |k|
        if k.match(/^#{RedisCache.cache_prefix}/).present?
          redis.del(k)
        end
      end
      puts "Done!"
    else
      puts "Redis Cache is not configured"
    end
  end

end
