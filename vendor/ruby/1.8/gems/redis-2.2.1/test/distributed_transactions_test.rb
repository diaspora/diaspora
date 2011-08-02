# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

test "MULTI/DISCARD" do |r|
  @foo = nil

  assert_raise Redis::Distributed::CannotDistribute do
    r.multi { @foo = 1 }
  end

  assert nil == @foo

  assert_raise Redis::Distributed::CannotDistribute do
    r.discard
  end
end

test "WATCH/UNWATCH" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.watch("foo")
  end

  assert_raise Redis::Distributed::CannotDistribute do
    r.unwatch
  end
end

