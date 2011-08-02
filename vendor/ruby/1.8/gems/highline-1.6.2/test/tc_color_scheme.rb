#!/usr/local/bin/ruby -w

# tc_color_scheme.rb
#
#  Created by Jeremy Hinegardner on 2007-01-24.  
#  Copyright 2007 Jeremy Hinegardner. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details.

require "test/unit"

require "highline"
require "stringio"

class TestColorScheme < Test::Unit::TestCase
  def setup
    @input    = StringIO.new
    @output   = StringIO.new
    @terminal = HighLine.new(@input, @output)
    
    @old_color_scheme = HighLine.color_scheme
  end
  
  def teardown
    HighLine.color_scheme = @old_color_scheme
  end

  def test_using_color_scheme
    assert_equal(false,HighLine.using_color_scheme?)

    HighLine.color_scheme = HighLine::ColorScheme.new
    assert_equal(true,HighLine.using_color_scheme?)
  end

  def test_scheme
    HighLine.color_scheme = HighLine::SampleColorScheme.new

    @terminal.say("This should be <%= color('warning yellow', :warning) %>.")
    assert_equal("This should be \e[1m\e[33mwarning yellow\e[0m.\n",@output.string)
    @output.rewind
    
    @terminal.say("This should be <%= color('warning yellow', 'warning') %>.")
    assert_equal("This should be \e[1m\e[33mwarning yellow\e[0m.\n",@output.string)
    @output.rewind

    @terminal.say("This should be <%= color('warning yellow', 'WarNing') %>.")
    assert_equal("This should be \e[1m\e[33mwarning yellow\e[0m.\n",@output.string)
    @output.rewind

    # turn it back off, should raise an exception
    HighLine.color_scheme = @old_color_scheme
    assert_raises(NameError) {
      @terminal.say("This should be <%= color('nothing at all', :error) %>.")
    }
  end
end 
