require 'rubygems'
require File.dirname(__FILE__) + '/../lib/typhoeus.rb'
require 'json'

class Twitter
  include Typhoeus
  remote_defaults :on_success => lambda {|response| JSON.parse(response.body)},
                  :on_failure => lambda {|response| puts "error code: #{response.code}"},
                  :base_uri   => "http://search.twitter.com"

  define_remote_method :search, :path => '/search.json'
  define_remote_method :trends, :path => '/trends/:time_frame.json'
end

tweets = Twitter.search(:params => {:q => "railsconf"})
trends = Twitter.trends(:time_frame => :current)

# and then the calls don't actually happen until the first time you
# call a method on one of the objects returned from the remote_method

puts tweets.keys # it's a hash from parsed JSON