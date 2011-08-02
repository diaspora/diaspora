$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

require "cutest"
require "logger"
require "stringio"

begin
  require "ruby-debug"
rescue LoadError
end

PORT    = 6379
OPTIONS = {:port => PORT, :db => 15, :timeout => 3}
NODES   = ["redis://127.0.0.1:6379/15"]

def init(redis)
  begin
    redis.flushdb
    redis.select 14
    redis.flushdb
    redis.select 15
    redis
  rescue Errno::ECONNREFUSED
    puts <<-EOS

      Cannot connect to Redis.

      Make sure Redis is running on localhost, port 6379.
      This testing suite connects to the database 15.

      To install redis:
        visit <http://code.google.com/p/redis/>.

      To start the server:
        rake start

      To stop the server:
        rake stop

    EOS
    exit 1
  end
end

$VERBOSE = true

require "redis"

def driver
  Redis::Connection.drivers.last.to_s.split("::").last.downcase.to_sym
end

if driver == :synchrony
  # Make cutest fiber + eventmachine aware if the synchrony driver is used.
  undef test if defined? test
  def test(name = nil, &block)
    cutest[:test] = name

    blk = Proc.new do
      prepare.each { |blk| blk.call }
      block.call(setup && setup.call)
    end

    t = Thread.current[:cutest]
    if defined? EventMachine
      EM.synchrony do
        Thread.current[:cutest] = t
        blk.call
        EM.stop
      end
    else
      blk.call
    end
  end

  class Wire < Fiber
    # We cannot run this fiber explicitly because EM schedules it. Resuming the
    # current fiber on the next tick to let the reactor do work.
    def self.pass
      f = Fiber.current
      EM.next_tick { f.resume }
      Fiber.yield
    end

    def self.sleep(sec)
      EM::Synchrony.sleep(sec)
    end

    def initialize(&blk)
      super

      # Schedule run in next tick
      EM.next_tick { resume }
    end

    def join
      self.class.pass while alive?
    end
  end
else
  class Wire < Thread
    def self.sleep(sec)
      Kernel.sleep(sec)
    end
  end
end

def capture_stderr
  stderr = $stderr
  $stderr = StringIO.new

  yield

  $stderr = stderr
end

def silent
  verbose, $VERBOSE = $VERBOSE, false

  begin
    yield
  ensure
    $VERBOSE = verbose
  end
end

def with_external_encoding(encoding)
  original_encoding = Encoding.default_external

  begin
    silent { Encoding.default_external = Encoding.find(encoding) }
    yield
  ensure
    silent { Encoding.default_external = original_encoding }
  end
end

def assert_nothing_raised(*exceptions)
  begin
    yield
  rescue *exceptions
    flunk(caller[1])
  end
end

