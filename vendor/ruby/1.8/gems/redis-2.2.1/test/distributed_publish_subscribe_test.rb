# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require "redis/distributed"

setup do
  log = StringIO.new
  init Redis::Distributed.new(NODES, :logger => ::Logger.new(log))
end

test "SUBSCRIBE and UNSUBSCRIBE" do |r|
  assert_raise Redis::Distributed::CannotDistribute do
    r.subscribe("foo", "bar") { }
  end

  assert_raise Redis::Distributed::CannotDistribute do
    r.subscribe("{qux}foo", "bar") { }
  end
end

test "SUBSCRIBE and UNSUBSCRIBE with tags" do |r|
  listening = false

  wire = Wire.new do
    r.subscribe("foo") do |on|
      on.subscribe do |channel, total|
        @subscribed = true
        @t1 = total
      end

      on.message do |channel, message|
        if message == "s1"
          r.unsubscribe
          @message = message
        end
      end

      on.unsubscribe do |channel, total|
        @unsubscribed = true
        @t2 = total
      end

      listening = true
    end
  end

  Wire.pass while !listening

  Redis::Distributed.new(NODES).publish("foo", "s1")

  wire.join

  assert @subscribed
  assert 1 == @t1
  assert @unsubscribed
  assert 0 == @t2
  assert "s1" == @message
end

test "SUBSCRIBE within SUBSCRIBE" do |r|
  listening = false
  @channels = []

  wire = Wire.new do
    r.subscribe("foo") do |on|
      on.subscribe do |channel, total|
        @channels << channel

        r.subscribe("bar") if channel == "foo"
        r.unsubscribe if channel == "bar"
      end

      listening = true
    end
  end

  Wire.pass while !listening

  Redis::Distributed.new(NODES).publish("foo", "s1")

  wire.join

  assert ["foo", "bar"] == @channels
end

test "other commands within a SUBSCRIBE" do |r|
  assert_raise RuntimeError do
    r.subscribe("foo") do |on|
      on.subscribe do |channel, total|
        r.set("bar", "s2")
      end
    end
  end
end

test "SUBSCRIBE without a block" do |r|
  assert_raise LocalJumpError do
    r.subscribe("foo")
  end
end

