require 'rubygems'
gem 'rack',        '>= 1.2.1'
gem 'addressable', '>= 2.2.2'

require 'test/unit'
if ENV['LEFTRIGHT']
  begin
    require 'leftright'
  rescue LoadError
    puts "Run `gem install leftright` to install leftright."
  end
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'faraday'

begin
  require 'ruby-debug'
  Debugger.start
rescue LoadError
end

module Faraday
  class TestCase < Test::Unit::TestCase
    LIVE_SERVER = case ENV['LIVE']
      when /^http/ then ENV['LIVE']
      when nil     then nil
      else 'http://localhost:4567'
    end

    def test_default
      assert true
    end
  end
end
