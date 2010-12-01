#!/usr/local/bin/ruby -w

# tc_import.rb
#
#  Created by James Edward Gray II on 2005-04-26.
#  Copyright 2005 Gray Productions. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details.

require "test/unit"

require "highline/import"
require "stringio"

class TestImport < Test::Unit::TestCase
  def test_import
    assert_respond_to(self, :agree)
    assert_respond_to(self, :ask)
    assert_respond_to(self, :choose)
    assert_respond_to(self, :say)
  end
  
  def test_or_ask
    old_terminal = $terminal
    
    input     = StringIO.new
    output    = StringIO.new
    $terminal = HighLine.new(input, output)  
    
    input << "10\n"
    input.rewind

    assert_equal(10, nil.or_ask("How much?  ", Integer))

    input.rewind

    assert_equal(20, "20".or_ask("How much?  ", Integer))
    assert_equal(20, 20.or_ask("How much?  ", Integer))
    
    assert_equal(10, 20.or_ask("How much?  ", Integer) { |q| q.in = 1..10 })
  ensure
    $terminal = old_terminal
  end
  
  def test_redirection
    old_terminal = $terminal
    
    $terminal = HighLine.new(nil, (output = StringIO.new))
    say("Testing...")
    assert_equal("Testing...\n", output.string)
  ensure
    $terminal = old_terminal
  end
end
