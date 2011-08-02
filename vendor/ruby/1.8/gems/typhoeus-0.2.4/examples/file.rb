require 'rubygems'
require File.dirname(__FILE__) + '/../lib/typhoeus.rb'


response = Typhoeus::Request.post(
  "http://video-feed.local",
  :params => {
    :file => File.new("file.rb")
  }
)

puts response.inspect