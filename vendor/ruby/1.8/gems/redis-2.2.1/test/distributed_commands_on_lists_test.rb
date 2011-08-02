# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

load './test/lint/lists.rb'

test "RPOPLPUSH" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.rpoplpush("foo", "bar")
  end
end

test "BRPOPLPUSH" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.brpoplpush("foo", "bar", 1)
  end
end

