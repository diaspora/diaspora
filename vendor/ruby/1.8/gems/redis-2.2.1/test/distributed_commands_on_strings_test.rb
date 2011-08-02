# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

load './test/lint/strings.rb'

test "MGET" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.mget("foo", "bar")
  end
end

test "MGET mapped" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.mapped_mget("foo", "bar")
  end
end

test "MSET" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.mset(:foo, "s1", :bar, "s2")
  end
end

test "MSET mapped" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.mapped_mset(:foo => "s1", :bar => "s2")
  end
end

test "MSETNX" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.set("foo", "s1")
    r.msetnx(:foo, "s2", :bar, "s3")
  end
end

test "MSETNX mapped" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.set("foo", "s1")
    r.mapped_msetnx(:foo => "s2", :bar => "s3")
  end
end

