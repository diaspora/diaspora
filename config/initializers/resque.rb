require File.join(Rails.root, 'app', 'models', 'jobs', 'base')
Dir[File.join(Rails.root, 'app', 'models', 'jobs', '*.rb')].each { |file| require file }
#config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))
#Resque.redis = Redis.new(:host => config['host'], :port => config['port'])
require 'resque'
