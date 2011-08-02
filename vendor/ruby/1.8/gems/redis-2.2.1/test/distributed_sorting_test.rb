# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

test "SORT" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.set("foo:1", "s1")
    r.set("foo:2", "s2")

    r.rpush("bar", "1")
    r.rpush("bar", "2")

    r.sort("bar", :get => "foo:*", :limit => [0, 1])
  end
end
