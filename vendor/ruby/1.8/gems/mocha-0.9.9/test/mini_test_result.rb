require 'stringio'
require 'test/unit/testcase'
require 'minitest/unit'

class MiniTestResult
  def self.parse_failure(raw)
    matches = %r{(Failure)\:\n([^\(]+)\(([^\)]+)\) \[([^\]]+)\]\:\n(.*)\n}m.match(raw)
    return nil unless matches
    Failure.new(matches[2], matches[3], [matches[4]], matches[5])
  end
  
  def self.parse_error(raw)
    matches = %r{(Error)\:\n([^\(]+)\(([^\)]+)\)\:\n(.+?)\n.+    (.*)\n}m.match(raw)
    return nil unless matches
    Error.new(matches[2], matches[3], matches[4], [matches[5]])
  end
  
  class Failure
    attr_reader :method, :test_case, :location, :message
    def initialize(method, test_case, location, message)
      @method, @test_case, @location, @message = method, test_case, location, message
    end
  end
  
  class Error
    class Exception
      attr_reader :message, :backtrace
      def initialize(message, location)
        @message, @backtrace = message, location
      end
    end
    
    attr_reader :method, :test_case, :exception
    def initialize(method, test_case, message, backtrace)
      @method, @test_case, @exception = method, test_case, Exception.new(message, backtrace)
    end
  end
  
  def initialize(runner, test)
    @runner, @test = runner, test
  end
  
  def failure_count
    @runner.failures
  end
  
  def assertion_count
    @test._assertions
  end
  
  def error_count
    @runner.errors
  end
  
  def passed?
    @test.passed?
  end
  
  def failures
    @runner.report.map { |puked| MiniTestResult.parse_failure(puked) }.compact
  end
  
  def errors
    @runner.report.map { |puked| MiniTestResult.parse_error(puked) }.compact
  end
  
  def failure_messages
    failures.map(&:message)
  end
  
  def error_messages
    errors.map { |e| e.exception.message }
  end
end