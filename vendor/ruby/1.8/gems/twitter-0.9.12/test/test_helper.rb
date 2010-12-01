require "test/unit"
require "pathname"
require "shoulda"
require "mocha"
require "fakeweb"

FakeWeb.allow_net_connect = false

dir = (Pathname(__FILE__).dirname + "../lib").expand_path
require dir + "twitter"

class Test::Unit::TestCase
end

def sample_image(filename)
  File.expand_path(File.dirname(__FILE__) + "/fixtures/" + filename)
end

def fixture_file(filename)
  return "" if filename == ""
  file_path = File.expand_path(File.dirname(__FILE__) + "/fixtures/" + filename)
  File.read(file_path)
end

def twitter_url(url)
  url =~ /^http/ ? url : "http://api.twitter.com#{url}"
end

def stub_get(url, filename, status=nil)
  options = {:body => fixture_file(filename)}
  options.merge!({:status => status}) unless status.nil?
  FakeWeb.register_uri(:get, twitter_url(url), options)
end

def stub_post(url, filename)
  FakeWeb.register_uri(:post, twitter_url(url), :body => fixture_file(filename))
end

def stub_put(url, filename)
  FakeWeb.register_uri(:put, twitter_url(url), :body => fixture_file(filename))
end

def stub_delete(url, filename)
  FakeWeb.register_uri(:delete, twitter_url(url), :body => fixture_file(filename))
end
