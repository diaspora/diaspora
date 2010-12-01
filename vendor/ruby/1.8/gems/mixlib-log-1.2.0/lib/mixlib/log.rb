#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'logger'
require 'mixlib/log/formatter'

module Mixlib
  module Log
  
    @logger = nil
    @@levels = { :debug=>Logger::DEBUG, :info=>Logger::INFO, :warn=>Logger::WARN, :error=>Logger::ERROR, :fatal=>Logger::FATAL}
    
    ##
    # init always returns a configured logger
    # and creates a new one if it doesn't yet exist
    ##
    def logger
      @logger || init
    end

    def logger=(value)
      @logger=value
    end
      
    # Use Mixlib::Log.init when you want to set up the logger manually.  Arguments to this method
    # get passed directly to Logger.new, so check out the documentation for the standard Logger class
    # to understand what to do here.
    #
    # If this method is called with no arguments, it will log to STDOUT at the :info level.
    #
    # It also configures the Logger instance it creates to use the custom Mixlib::Log::Formatter class.
    def init(*opts)
      @logger = (opts.empty? ? Logger.new(STDOUT) : Logger.new(*opts))
      @logger.formatter = Mixlib::Log::Formatter.new()
      @logger.level = Logger::WARN
      @logger
    end
    
    # Sets the level for the Logger object by symbol.  Valid arguments are:
    #
    #  :debug
    #  :info
    #  :warn
    #  :error
    #  :fatal
    #
    # Throws an ArgumentError if you feed it a bogus log level.
    def level=(l)
      lv = @@levels[l]
      raise ArgumentError, "Log level must be one of :debug, :info, :warn, :error, or :fatal" if lv.nil?
      logger.level = lv
    end

    def level(lv=nil)
      if lv.nil?
        @@levels.find() {|l| logger.level==l[1]}[0]
      else
        self.level=(lv)
      end
    end
    
    # Passes any other method calls on directly to the underlying Logger object created with init. If
    # this method gets hit before a call to Mixlib::Logger.init has been made, it will call 
    # Mixlib::Logger.init() with no arguments.
    def method_missing(method_symbol, *args, &block)
      logger.send(method_symbol, *args, &block)
    end
    
  end
end
