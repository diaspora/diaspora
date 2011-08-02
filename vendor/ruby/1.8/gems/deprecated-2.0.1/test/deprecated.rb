#!/usr/bin/env ruby

require 'lib/deprecated.rb'
require 'test/unit'

# this class is used to test the deprecate functionality
class DummyClass
  def monkey
    return true
  end

  deprecate :monkey
end

# we want exceptions for testing here.
Deprecate.set_action(:throw)

class DeprecateTest < Test::Unit::TestCase
  def test_set_action
     
    assert_raise(DeprecatedError) { raise StandardError.new unless DummyClass.new.monkey }

    Deprecate.set_action(proc { |msg| raise DeprecatedError.new("#{msg} is deprecated.") })

    assert_raise(DeprecatedError) { raise StandardError.new unless DummyClass.new.monkey }
   

    # set to warn and make sure our return values are getting through.
    Deprecate.set_action(:warn)
    
    assert_nothing_raised(DeprecatedError) { raise StandardError.new unless DummyClass.new.monkey } 
  end
end
