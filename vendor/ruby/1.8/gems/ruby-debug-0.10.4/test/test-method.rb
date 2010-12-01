#!/usr/bin/env ruby
require 'test/unit'

# require 'rubygems'
# require 'ruby-debug'; Debugger.start(:post_mortem => true)

class TestMethod < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  def test_basic
    testname='method'
    Dir.chdir(@@SRC_DIR) do 
      script = File.join('data', testname + '.cmd')
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} -- classes.rb"))
      begin 
        require 'methodsig'
        testname='methodsig'
        script = File.join('data', testname + '.cmd')
        assert_equal(true, 
                     run_debugger(testname,
                                  "--script #{script} -- classes.rb"))
      rescue LoadError
        puts "Skipping method sig test"
      end
    end
  end
end
