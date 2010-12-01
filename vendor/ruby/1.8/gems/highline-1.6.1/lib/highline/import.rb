#!/usr/local/bin/ruby -w

# import.rb
#
#  Created by James Edward Gray II on 2005-04-26.
#  Copyright 2005 Gray Productions. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details.

require "highline"
require "forwardable"

$terminal = HighLine.new

#
# <tt>require "highline/import"</tt> adds shortcut methods to Kernel, making
# agree(), ask(), choose() and say() globally available.  This is handy for
# quick and dirty input and output.  These methods use the HighLine object in
# the global variable <tt>$terminal</tt>, which is initialized to used
# <tt>$stdin</tt> and <tt>$stdout</tt> (you are free to change this).
# Otherwise, these methods are identical to their HighLine counterparts, see that
# class for detailed explanations.
#
module Kernel
  extend Forwardable
  def_delegators :$terminal, :agree, :ask, :choose, :say
end

class Object
  # 
  # Tries this object as a _first_answer_ for a HighLine::Question.  See that
  # attribute for details.
  # 
  # *Warning*:  This Object will be passed to String() before set.
  # 
  def or_ask( *args, &details )
    ask(*args) do |question|
      question.first_answer = String(self) unless nil?
      
      details.call(question) unless details.nil?
    end
  end
end
