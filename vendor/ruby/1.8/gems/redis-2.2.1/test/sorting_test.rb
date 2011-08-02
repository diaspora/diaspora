# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

setup do
  init Redis.new(OPTIONS)
end

test "SORT" do |r|
  r.set("foo:1", "s1")
  r.set("foo:2", "s2")

  r.rpush("bar", "1")
  r.rpush("bar", "2")

  assert ["s1"] == r.sort("bar", :get => "foo:*", :limit => [0, 1])
  assert ["s2"] == r.sort("bar", :get => "foo:*", :limit => [0, 1], :order => "desc alpha")
end

test "SORT with an array of GETs" do |r|
  r.set("foo:1:a", "s1a")
  r.set("foo:1:b", "s1b")

  r.set("foo:2:a", "s2a")
  r.set("foo:2:b", "s2b")

  r.rpush("bar", "1")
  r.rpush("bar", "2")

  assert ["s1a", "s1b"] == r.sort("bar", :get => ["foo:*:a", "foo:*:b"], :limit => [0, 1])
  assert ["s2a", "s2b"] == r.sort("bar", :get => ["foo:*:a", "foo:*:b"], :limit => [0, 1], :order => "desc alpha")
end

test "SORT with STORE" do |r|
  r.set("foo:1", "s1")
  r.set("foo:2", "s2")

  r.rpush("bar", "1")
  r.rpush("bar", "2")

  r.sort("bar", :get => "foo:*", :store => "baz")
  assert ["s1", "s2"] == r.lrange("baz", 0, -1)
end

