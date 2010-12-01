#!/usr/bin/env ruby
require 'test/unit'

# require 'rubygems'
# require 'ruby-debug'; Debugger.start(:post_mortem => true)

# Test the --emacs-basic option.
class TestEmacsBasic < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
  defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper.rb')
  
  include TestHelper
  
  def test_basic
    testname='emacs_basic'
    Dir.chdir(@@SRC_DIR) do 
      script = File.join('data', testname + '.cmd')
      assert_equal(true, 
                   run_debugger(testname,
                                "--emacs-basic --script #{script} -- gcd.rb 3 5"))
    end
  end
end
