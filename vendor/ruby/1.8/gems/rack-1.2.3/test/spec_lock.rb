require 'rack/lock'
require 'rack/mock'

class Lock
  attr_reader :synchronized

  def initialize
    @synchronized = false
  end

  def synchronize
    @synchronized = true
    yield
  end
end

describe Rack::Lock do
  should "call synchronize on lock" do
    lock = Lock.new
    env = Rack::MockRequest.env_for("/")
    app = Rack::Lock.new(lambda { |inner_env| }, lock)
    lock.synchronized.should.equal false
    app.call(env)
    lock.synchronized.should.equal true
  end

  should "set multithread flag to false" do
    app = Rack::Lock.new(lambda { |env| env['rack.multithread'] })
    app.call(Rack::MockRequest.env_for("/")).should.equal false
  end

  should "reset original multithread flag when exiting lock" do
    app = Rack::Lock.new(lambda { |env| env })
    app.call(Rack::MockRequest.env_for("/"))['rack.multithread'].should.equal true
  end
end
