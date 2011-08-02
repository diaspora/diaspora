require 'helper'

class TestResqueEnsureConnected < Test::Unit::TestCase
  class FakeJob
    @queue = 'test'
    def self.perform
    end
  end

  class FakeHandler
    @invoked = false
    def verify_active_connections!
      @@invoked = true
      puts 'invoked'
      puts @@invoked
    end
    def self.invoked?
      @invoked
    end
  end

  should "ensure verify connections after forking process" do
    Resque.redis.flushall
    worker = Resque::Worker.new(:jobs)
    Resque::Job.create(:jobs, FakeJob, 20, '/tmp')

    handler = FakeHandler.new
    ActiveRecord::Base.connection_handler = handler
    puts FakeHandler.invoked?
    worker.work(0)

    puts 'assert'
    puts FakeHandler.invoked?
    puts handler.inspect
    assert FakeHandler.invoked?
    #WTF? why is this assertion failing?
  end
end
