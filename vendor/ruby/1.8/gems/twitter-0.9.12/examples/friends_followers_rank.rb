require File.join(File.dirname(__FILE__), '..', 'lib', 'twitter')
require File.join(File.dirname(__FILE__), 'helpers', 'config_store')
require 'pp'

config = ConfigStore.new("#{ENV['HOME']}/.twitter")
oauth = Twitter::OAuth.new(config['token'], config['secret'])
oauth.authorize_from_access(config['atoken'], config['asecret'])
client = Twitter::Base.new(oauth)

puts "Friends List, sorted by followers"
client.friends.sort {|a, b| a.followers_count <=> b.followers_count}.reverse.each {|f| puts "#{f.name} (@#{f.screen_name}) - #{f.followers_count}"}

puts "\n\nFollowers List, sorted by followers"
client.followers.sort {|a, b| a.followers_count <=> b.followers_count}.reverse.each {|f| puts "#{f.name} (@#{f.screen_name}) - #{f.followers_count}"}
