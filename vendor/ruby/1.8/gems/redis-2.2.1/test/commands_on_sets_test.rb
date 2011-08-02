# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

setup do
  init Redis.new(OPTIONS)
end

load './test/lint/sets.rb'

test "SMOVE" do |r|
  r.sadd "foo", "s1"
  r.sadd "bar", "s2"

  assert r.smove("foo", "bar", "s1")
  assert r.sismember("bar", "s1")
end

test "SINTER" do |r|
  r.sadd "foo", "s1"
  r.sadd "foo", "s2"
  r.sadd "bar", "s2"

  assert ["s2"] == r.sinter("foo", "bar")
end

test "SINTERSTORE" do |r|
  r.sadd "foo", "s1"
  r.sadd "foo", "s2"
  r.sadd "bar", "s2"

  r.sinterstore("baz", "foo", "bar")

  assert ["s2"] == r.smembers("baz")
end

test "SUNION" do |r|
  r.sadd "foo", "s1"
  r.sadd "foo", "s2"
  r.sadd "bar", "s2"
  r.sadd "bar", "s3"

  assert ["s1", "s2", "s3"] == r.sunion("foo", "bar").sort
end

test "SUNIONSTORE" do |r|
  r.sadd "foo", "s1"
  r.sadd "foo", "s2"
  r.sadd "bar", "s2"
  r.sadd "bar", "s3"

  r.sunionstore("baz", "foo", "bar")

  assert ["s1", "s2", "s3"] == r.smembers("baz").sort
end

test "SDIFF" do |r|
  r.sadd "foo", "s1"
  r.sadd "foo", "s2"
  r.sadd "bar", "s2"
  r.sadd "bar", "s3"

  assert ["s1"] == r.sdiff("foo", "bar")
  assert ["s3"] == r.sdiff("bar", "foo")
end

test "SDIFFSTORE" do |r|
  r.sadd "foo", "s1"
  r.sadd "foo", "s2"
  r.sadd "bar", "s2"
  r.sadd "bar", "s3"

  r.sdiffstore("baz", "foo", "bar")

  assert ["s1"] == r.smembers("baz")
end


