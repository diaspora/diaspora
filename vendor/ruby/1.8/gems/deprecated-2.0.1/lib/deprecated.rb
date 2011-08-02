#
# Deprecated - handle deprecating and executing deprecated code
#
# Version:: 2.0.1
# Author:: Erik Hollensbe
# License:: BSD
# Copyright:: Copyright (c) 2006 Erik Hollensbe
# Contact:: erik@hollensbe.org
#
# Deprecated is intended to ease the programmer's control over
# deprecating and handling deprecated code.
#
# Usage is simple:
#
#   # require 'rubygems' if need be
#   require 'deprecated'
#   
#   class Foo
#     private
#     # rename the original function and make it private
#     def monkey
#       do stuff...
#     end
#     # deprecate the function, this will create a 'monkey' method
#     # that will call the deprecate warnings
#     deprecate :monkey, :private
#   end
#
# The 'deprecated' call is injected into the 'Module' class at
# require-time. This allows all classes that are newly-created to
# access the 'deprecate' functionality. The deprecate definition must
# follow the method definition. You may only define one deprecated
# function per call.
#
# Methods deprecated default to 'public'. This is due to a limitation
# in how Ruby handles permission definition. If you're aware of a
# workaround to this problem, please let me know.
#
# You can however change this by providing an optional trailing
# parameter to the 'deprecate' call:
#
# * :public - set the created method to be public
# * :protected - set the created method to be protected
# * :private - set the created method to be private
#
# Note: It's highly recommended that you make your original methods
# private so that they cannot be accessed by outside code.
#
# Deprecated.set_action can change the default action (which is a
# warning printed to stderr) if you prefer. This is ideal for code
# sweeps where deprecated calls have to be removed. Please see the
# documentation for this method to get an idea of the options that are
# available.
#
#--
#
# The compilation of software known as deprecate.rb is distributed under the
# following terms:
# Copyright (C) 2005-2006 Erik Hollensbe. All rights reserved.
#
# Redistribution and use in source form, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer:
#
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
#++

module Deprecated
  
  #
  # set_action defines the action that will be taken when code marked
  # deprecated is encountered. There are several stock options:
  #
  # * :warn -- print a warning message to stderr (default)
  # * :die  -- warn and then terminate the program with error level -1
  # * :throw -- throw a DeprecatedError with the message
  #
  # If a proc is passed instead, it will execute that instead. This
  # procedure is passed a single argument, which is the name (NOT the
  # symbol) of the method in Class#meth syntax that was called. This
  # does not interrupt the calling process (unless you do so
  # yourself).
  #
  # The second argument is the message provided to warnings and throw
  # errors and so on. This message is a sprintf-like formatted string
  # that takes one argument, which is the Class#meth name as a string.
  # This message is not used when you define your own procedure.
  # 
  # Note: ALL code that is marked deprecated will behave in the manner
  # that was set at the last call to set_action.
  #
  # Ex:
  #
  #    # throws with the error message saying: "FIXME: Class#meth"
  #    Deprecated.set_action(:throw, "FIXME: %s")
  #
  #    # emails your boss everytime you run deprecated code
  #    Deprecated.set_action proc do |msg|
  #       f = IO.popen('mail boss@company -s "Joe still hasn't fixed %s"' % msg, 'w')
  #       f.puts("Sorry, I still haven't fixed %s, please stop making me go to meetings.\n" % msg)
  #       f.close
  #    end
  #
  
  @@action = nil
  
  def Deprecated.action
    return @@action
  end
  
  def Deprecated.set_action(action, message="%s is deprecated.")
    if action.kind_of? Proc
      @@action = action
      return
    end
    
    case action
    when :warn
      @@action = proc do |msg|
        warn(message % msg)
      end
    when :die
      @@action = proc do |msg|
        warn(message % msg)
        exit(-1)
      end
    when :throw
      @@action = proc do |msg| 
        raise DeprecatedError.new(message % msg)
      end
    end
  end
end

#
# This is the class of the errors that the 'Deprecated' module will
# throw if the action type is set to ':throw'.
#
# See Deprecated.set_action for more information.
#
class DeprecatedError < Exception
  attr_reader :message
  def initialize(msg=nil)
    @message = msg
  end
end

#
# Start - inject the 'deprecated' method into the 'Module' class and
# set the default action to warn.
#

Module.send(:define_method, :deprecate, 
            proc do |*args|
              sym = args.shift
              protection = args.shift || :public
              
              unless sym
                raise DeprecatedError.new("Invalid number of arguments passed to 'deprecated' function")
              end
             
              old_method = self.instance_method(sym)
              
              define_method(sym) do |*sendparams|
                Deprecated.action.call(self.class.to_s + '#' + sym.to_s)
                new_method = self.class.instance_method(sym)
                retval = old_method.bind(self).call(*sendparams)
                new_method.bind(self)
                return retval
              end
              
              case protection
              when :public
                public(sym)
              when :private
                private(sym)
              when :protected
                protected(sym)
              end
              
            end)

Deprecated.set_action(:warn)

Deprecate = Deprecated
