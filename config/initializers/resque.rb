#config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))
#Resque.redis = Redis.new(:host => config['host'], :port => config['port'])
require 'resque'
