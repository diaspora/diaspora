$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'childprocess'
require 'spec'
require 'spec/autorun'
require 'tempfile'
require "socket"

module ChildProcessSpecHelper
  RUBY = defined?(Gem) ? Gem.ruby : 'ruby'

  def ruby_process(*args)
    @process = ChildProcess.build(RUBY , *args)
  end

  def sleeping_ruby
    ruby_process("-e", "sleep")
  end

  def ignored(signal)
    code = <<-RUBY
      trap(#{signal.inspect}, "IGNORE")
      sleep
    RUBY

    ruby_process tmp_script(code)
  end

  def write_env(path)
    code = <<-RUBY
      File.open(#{path.inspect}, "w") { |f| f << ENV.inspect }
    RUBY

    ruby_process tmp_script(code)
  end

  def write_argv(path, *args)
    code = <<-RUBY
      File.open(#{path.inspect}, "w") { |f| f << ARGV.inspect }
    RUBY

    ruby_process(tmp_script(code), *args)
  end

  def exit_with(exit_code)
    ruby_process(tmp_script("exit(#{exit_code})"))
  end

  def with_env(hash)
    hash.each { |k,v| ENV[k] = v }
    begin
      yield
    ensure
      hash.each_key { |k| ENV[k] = nil }
    end
  end

  def tmp_script(code)
    tf = Tempfile.new("childprocess-temp")
    tf << code
    tf.close

    puts code if $DEBUG

    tf.path
  end

  def within(seconds, &blk)
    end_time   = Time.now + seconds
    ok         = false
    last_error = nil

    until ok || Time.now >= end_time
      begin
        ok = yield
      rescue Spec::Expectations::ExpectationNotMetError => last_error
      end
    end

    raise last_error unless ok
  end

  def ruby(code)
    ruby_process(tmp_script(code))
  end

end # ChildProcessSpecHelper

Thread.abort_on_exception = true

Spec::Runner.configure do |config|
  config.include(ChildProcessSpecHelper)
  config.after(:each) {
    @process && @process.alive? && @process.stop
  }
end
