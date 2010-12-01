# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.


HERE = File.dirname(__FILE__)
%w(lib ext bin test).each do |dir| 
  $LOAD_PATH.unshift "#{HERE}/../#{dir}"
end

require 'rubygems'
require 'test/unit'
require 'net/http'
require 'timeout'
require 'cgi/session'
require 'fileutils'
require 'benchmark'
require 'digest/sha1'
require 'uri'
require 'stringio'
require 'pp'

require 'mongrel'
require 'mongrel/stats'

if ENV['DEBUG']
  require 'ruby-debug'
  Debugger.start
end

def redirect_test_io
  orig_err = STDERR.dup
  orig_out = STDOUT.dup
  STDERR.reopen("test_stderr.log")
  STDOUT.reopen("test_stdout.log")

  begin
    yield
  ensure
    STDERR.reopen(orig_err)
    STDOUT.reopen(orig_out)
  end
end
    
# Either takes a string to do a get request against, or a tuple of [URI, HTTP] where
# HTTP is some kind of Net::HTTP request object (POST, HEAD, etc.)
def hit(uris)
  results = []
  uris.each do |u|
    res = nil

    if u.kind_of? String
      res = Net::HTTP.get(URI.parse(u))
    else
      url = URI.parse(u[0])
      res = Net::HTTP.new(url.host, url.port).start {|h| h.request(u[1]) }
    end

    assert res != nil, "Didn't get a response: #{u}"
    results << res
  end

  return results
end
