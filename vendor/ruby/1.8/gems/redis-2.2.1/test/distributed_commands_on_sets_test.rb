# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

load './test/lint/sets.rb'

test "SMOVE" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.sadd "foo", "s1"
    r.sadd "bar", "s2"

    r.smove("foo", "bar", "s1")
  end
end

test "SINTER" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.sadd "foo", "s1"
    r.sadd "foo", "s2"
    r.sadd "bar", "s2"

    r.sinter("foo", "bar")
  end
end

test "SINTERSTORE" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.sadd "foo", "s1"
    r.sadd "foo", "s2"
    r.sadd "bar", "s2"

    r.sinterstore("baz", "foo", "bar")
  end
end

test "SUNION" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.sadd "foo", "s1"
    r.sadd "foo", "s2"
    r.sadd "bar", "s2"
    r.sadd "bar", "s3"

    r.sunion("foo", "bar")
  end
end

test "SUNIONSTORE" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.sadd "foo", "s1"
    r.sadd "foo", "s2"
    r.sadd "bar", "s2"
    r.sadd "bar", "s3"

    r.sunionstore("baz", "foo", "bar")
  end
end

test "SDIFF" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.sadd "foo", "s1"
    r.sadd "foo", "s2"
    r.sadd "bar", "s2"
    r.sadd "bar", "s3"

    r.sdiff("foo", "bar")
  end
end

test "SDIFFSTORE" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.sadd "foo", "s1"
    r.sadd "foo", "s2"
    r.sadd "bar", "s2"
    r.sadd "bar", "s3"

    r.sdiffstore("baz", "foo", "bar")
  end
end

