# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require File.expand_path("./redis_mock", File.dirname(__FILE__))

include RedisMock::Helper

require "redis/distributed"

setup do
  log = StringIO.new
  [init(Redis::Distributed.new(NODES, :logger => ::Logger.new(log))), log]
end

$TEST_PIPELINING = false

load File.expand_path("./lint/internals.rb", File.dirname(__FILE__))

test "provides a meaningful inspect" do |r, _|
  nodes = ["redis://localhost:6379/15", *NODES]
  @r = Redis::Distributed.new nodes

  node_info = nodes.map do |node|
    "#{node} (Redis v#{@r.info.first["redis_version"]})"
  end
  assert "#<Redis client v#{Redis::VERSION} connected to #{node_info.join(', ')}>" == @r.inspect
end
