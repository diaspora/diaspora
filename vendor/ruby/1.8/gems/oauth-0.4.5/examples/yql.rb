#!/usr/bin/env ruby -rubygems

# Sample queries:
#  ./yql.rb --consumer-key <key> --consumer-secret <secret> "show tables"
#  ./yql.rb --consumer-key <key> --consumer-secret <secret> "select * from flickr.photos.search where text='Cat' limit 10"

require 'oauth'
require 'optparse'
require 'json'
require 'pp'

options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options] <query>"

  opts.on("--consumer-key KEY", "Specifies the consumer key to use.") do |v|
    options[:consumer_key] = v
  end

  opts.on("--consumer-secret SECRET", "Specifies the consumer secret to use.") do |v|
    options[:consumer_secret] = v
  end
end

option_parser.parse!
query = ARGV.pop
query = STDIN.read if query == "-"

if options[:consumer_key].nil? || options[:consumer_secret].nil? || query.nil?
  puts option_parser.help
  exit 1
end

consumer = OAuth::Consumer.new \
  options[:consumer_key],
  options[:consumer_secret],
  :site => "http://query.yahooapis.com"

access_token = OAuth::AccessToken.new(consumer)

response = access_token.request(:get, "/v1/yql?q=#{OAuth::Helper.escape(query)}&format=json")
rsp = JSON.parse(response.body)
pp rsp
