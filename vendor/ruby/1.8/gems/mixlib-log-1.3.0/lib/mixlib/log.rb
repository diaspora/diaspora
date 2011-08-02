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
require 'mixlib/log/version'
require 'mixlib/log/formatter'

module Mixlib
  module Log

    @logger, @loggers = nil

    LEVELS = { :debug=>Logger::DEBUG, :info=>Logger::INFO, :warn=>Logger::WARN, :error=>Logger::ERROR, :fatal=>Logger::FATAL}.freeze
    LEVEL_NAMES = LEVELS.invert.freeze


    def reset!
      @logger, @loggers = nil, nil
    end

    # An Array of log devices that will be logged to. Defaults to just the default
    # @logger log device, but you can push to this array to add more devices.
    def loggers
      @loggers ||= [logger]
    end

    ##
    # init always returns a configured logger
    # and creates a new one if it doesn't yet exist
    ##
    def logger
      @logger || init
    end

    # Sets the log device to +new_log_device+. Any additional loggers
    # that had been added to the +loggers+ array will be cleared.
    def logger=(new_log_device)
      reset!
      @logger=new_log_device
    end

    def use_log_devices(other)
      if other.respond_to?(:loggers) && other.respond_to?(:logger)
        @loggers = other.loggers
        @logger = other.logger
      elsif other.kind_of?(Array)
        @loggers = other
        @logger = other.first
      else
        msg = "#use_log_devices takes a Mixlib::Log object or array of log devices. " <<
              "You gave: #{other.inspect}"
        raise ArgumentError, msg
      end
    end

    # Use Mixlib::Log.init when you want to set up the logger manually.  Arguments to this method
    # get passed directly to Logger.new, so check out the documentation for the standard Logger class
    # to understand what to do here.
    #
    # If this method is called with no arguments, it will log to STDOUT at the :info level.
    #
    # It also configures the Logger instance it creates to use the custom Mixlib::Log::Formatter class.
    def init(*opts)
      reset!
      @logger = logger_for(*opts)
      @logger.formatter = Mixlib::Log::Formatter.new() if @logger.respond_to?(:formatter=)
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
    def level=(new_level)
      level_int = LEVEL_NAMES.key?(new_level) ? new_level : LEVELS[new_level]
      raise ArgumentError, "Log level must be one of :debug, :info, :warn, :error, or :fatal" if level_int.nil?
      loggers.each {|l| l.level = level_int }
    end

    def level(new_level=nil)
      if new_level.nil?
        LEVEL_NAMES[logger.level]
      else
        self.level=(new_level)
      end
    end

    # Define the standard logger methods on this class programmatically.
    # No need to incur method_missing overhead on every log call.
    [:debug, :info, :warn, :error, :fatal].each do |method_name|
      class_eval(<<-METHOD_DEFN, __FILE__, __LINE__)
        def #{method_name}(msg=nil, &block)
          loggers.each {|l| l.#{method_name}(msg, &block) }
        end
      METHOD_DEFN
    end

    # Define the methods to interrogate the logger for the current log level.
    # Note that we *only* query the default logger (@logger) and not any other
    # loggers that may have been added, even though it is possible to configure
    # two (or more) loggers at different log levels.
    [:debug?, :info?, :warn?, :error?, :fatal?].each do |method_name|
      class_eval(<<-METHOD_DEFN, __FILE__, __LINE__)
        def #{method_name}
          logger.#{method_name}
        end
      METHOD_DEFN
    end

    def <<(msg)
      loggers.each {|l| l << msg }
    end

    def add(severity, message = nil, progname = nil, &block)
      loggers.each {|l| l.add(severity, message = nil, progname = nil, &block) }
    end

    alias :log :add

    # Passes any other method calls on directly to the underlying Logger object created with init. If
    # this method gets hit before a call to Mixlib::Logger.init has been made, it will call
    # Mixlib::Logger.init() with no arguments.
    def method_missing(method_symbol, *args, &block)
      loggers.each {|l| l.send(method_symbol, *args, &block) }
    end

    private

    def logger_for(*opts)
      if opts.empty?
        Logger.new(STDOUT)
      elsif LEVELS.keys.inject(true) {|quacks, level| quacks && opts.first.respond_to?(level)}
        opts.first
      else
        Logger.new(*opts)
      end
    end

  end
end
