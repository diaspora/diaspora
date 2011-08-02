# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

test "SAVE and BGSAVE" do |r|
  assert_nothing_raised do
    r.save
  end

  assert_nothing_raised do
    r.bgsave
  end
end

test "LASTSAVE" do |r|
  assert r.lastsave.all? { |t| Time.at(t) <= Time.now }
end

