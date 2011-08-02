$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'cucumber/platform'
require 'cucumber/parser'
require 'cucumber/step_mother'
require 'cucumber/cli/main'
require 'cucumber/broadcaster'
require 'cucumber/step_definitions'

module Cucumber
  class << self
    attr_accessor :wants_to_quit
    
    def logger
      return @log if @log
      @log = Logger.new(STDOUT)
      @log.level = Logger::INFO
      @log
    end
    
    def logger=(logger)
      @log = logger
    end
  end
end