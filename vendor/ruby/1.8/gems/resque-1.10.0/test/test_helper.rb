dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'
$TESTING = true
require 'test/unit'
require 'rubygems'
require 'resque'

begin
  require 'leftright'
rescue LoadError
end


#
# make sure we can run redis
#

if !system("which redis-server")
  puts '', "** can't find `redis-server` in your path"
  puts "** try running `sudo rake install`"
  abort ''
end


#
# start our own redis when the tests start,
# kill it when they end
#

at_exit do
  next if $!

  if defined?(MiniTest)
    exit_code = MiniTest::Unit.new.run(ARGV)
  else
    exit_code = Test::Unit::AutoRunner.run
  end

  pid = `ps -A -o pid,command | grep [r]edis-test`.split(" ")[0]
  puts "Killing test redis server..."
  `rm -f #{dir}/dump.rdb`
  Process.kill("KILL", pid.to_i)
  exit exit_code
end

puts "Starting redis for testing at localhost:9736..."
`redis-server #{dir}/redis-test.conf`
Resque.redis = 'localhost:9736'


##
# test/spec/mini 3
# http://gist.github.com/25455
# chris@ozmm.org
#
def context(*args, &block)
  return super unless (name = args.first) && block
  require 'test/unit'
  klass = Class.new(defined?(ActiveSupport::TestCase) ? ActiveSupport::TestCase : Test::Unit::TestCase) do
    def self.test(name, &block)
      define_method("test_#{name.gsub(/\W/,'_')}", &block) if block
    end
    def self.xtest(*args) end
    def self.setup(&block) define_method(:setup, &block) end
    def self.teardown(&block) define_method(:teardown, &block) end
  end
  (class << klass; self end).send(:define_method, :name) { name.gsub(/\W/,'_') }
  klass.class_eval &block
end

##
# Helper to perform job classes
#
module PerformJob
  def perform_job(klass, *args)
    resque_job = Resque::Job.new(:testqueue, 'class' => klass, 'args' => args)
    resque_job.perform
  end
end

#
# fixture classes
#

class SomeJob
  def self.perform(repo_id, path)
  end
end

class SomeIvarJob < SomeJob
  @queue = :ivar
end

class SomeMethodJob < SomeJob
  def self.queue
    :method
  end
end

class BadJob
  def self.perform
    raise "Bad job!"
  end
end

class GoodJob
  def self.perform(name)
    "Good job, #{name}"
  end
end

class BadJobWithSyntaxError
  def self.perform
    raise SyntaxError, "Extra Bad job!"
  end
end
