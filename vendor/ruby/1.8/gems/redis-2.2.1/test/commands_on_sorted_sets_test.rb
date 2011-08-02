# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

setup do
  init Redis.new(OPTIONS)
end

load './test/lint/sorted_sets.rb'

test "ZCOUNT" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"

  assert 2 == r.zcount("foo", 2, 3)
end

test "ZUNIONSTORE" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "bar", 2, "s2"
  r.zadd "foo", 3, "s3"
  r.zadd "bar", 4, "s4"

  assert 4 == r.zunionstore("foobar", ["foo", "bar"])
  assert ["s1", "s2", "s3", "s4"] == r.zrange("foobar", 0, -1)
end

test "ZUNIONSTORE with WEIGHTS" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 3, "s3"
  r.zadd "bar", 20, "s2"
  r.zadd "bar", 40, "s4"

  assert 4 == r.zunionstore("foobar", ["foo", "bar"])
  assert ["s1", "s3", "s2", "s4"] == r.zrange("foobar", 0, -1)

  assert 4 == r.zunionstore("foobar", ["foo", "bar"], :weights => [10, 1])
  assert ["s1", "s2", "s3", "s4"] == r.zrange("foobar", 0, -1)
end

test "ZUNIONSTORE with AGGREGATE" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "bar", 4, "s2"
  r.zadd "bar", 3, "s3"

  assert 3 == r.zunionstore("foobar", ["foo", "bar"])
  assert ["s1", "s3", "s2"] == r.zrange("foobar", 0, -1)

  assert 3 == r.zunionstore("foobar", ["foo", "bar"], :aggregate => :min)
  assert ["s1", "s2", "s3"] == r.zrange("foobar", 0, -1)

  assert 3 == r.zunionstore("foobar", ["foo", "bar"], :aggregate => :max)
  assert ["s1", "s3", "s2"] == r.zrange("foobar", 0, -1)
end

test "ZINTERSTORE" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "bar", 2, "s1"
  r.zadd "foo", 3, "s3"
  r.zadd "bar", 4, "s4"

  assert 1 == r.zinterstore("foobar", ["foo", "bar"])
  assert ["s1"] == r.zrange("foobar", 0, -1)
end

test "ZINTERSTORE with WEIGHTS" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"
  r.zadd "bar", 20, "s2"
  r.zadd "bar", 30, "s3"
  r.zadd "bar", 40, "s4"

  assert 2 == r.zinterstore("foobar", ["foo", "bar"])
  assert ["s2", "s3"] == r.zrange("foobar", 0, -1)

  assert 2 == r.zinterstore("foobar", ["foo", "bar"], :weights => [10, 1])
  assert ["s2", "s3"] == r.zrange("foobar", 0, -1)

  assert "40" == r.zscore("foobar", "s2")
  assert "60" == r.zscore("foobar", "s3")
end

test "ZINTERSTORE with AGGREGATE" do |r|
  r.zadd "foo", 1, "s1"
  r.zadd "foo", 2, "s2"
  r.zadd "foo", 3, "s3"
  r.zadd "bar", 20, "s2"
  r.zadd "bar", 30, "s3"
  r.zadd "bar", 40, "s4"

  assert 2 == r.zinterstore("foobar", ["foo", "bar"])
  assert ["s2", "s3"] == r.zrange("foobar", 0, -1)
  assert "22" == r.zscore("foobar", "s2")
  assert "33" == r.zscore("foobar", "s3")

  assert 2 == r.zinterstore("foobar", ["foo", "bar"], :aggregate => :min)
  assert ["s2", "s3"] == r.zrange("foobar", 0, -1)
  assert "2" == r.zscore("foobar", "s2")
  assert "3" == r.zscore("foobar", "s3")

  assert 2 == r.zinterstore("foobar", ["foo", "bar"], :aggregate => :max)
  assert ["s2", "s3"] == r.zrange("foobar", 0, -1)
  assert "20" == r.zscore("foobar", "s2")
  assert "30" == r.zscore("foobar", "s3")
end

