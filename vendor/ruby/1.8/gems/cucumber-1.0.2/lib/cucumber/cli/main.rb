begin
  require 'gherkin'
rescue LoadError
  require 'rubygems'
  require 'gherkin'
end
require 'optparse'
require 'cucumber'
require 'logger'
require 'cucumber/parser'
require 'cucumber/feature_file'
require 'cucumber/cli/configuration'
require 'cucumber/cli/drb_client'

module Cucumber
  module Cli
    class Main
      class << self
        def execute(args)
          new(args).execute!
        end
      end

      def initialize(args, out_stream = STDOUT, error_stream = STDERR)
        @args         = args
        @out_stream   = out_stream

        @error_stream = error_stream
        @configuration = nil
      end

      def execute!(existing_runtime = nil)
        trap_interrupt
        return @drb_output if run_drb_client
        
        runtime = if existing_runtime
          existing_runtime.configure(configuration)
          existing_runtime
        else
          Runtime.new(configuration)
        end

        runtime.run!
        runtime.results.failure?
      rescue ProfilesNotDefinedError, YmlLoadError, ProfileNotFound => e
        @error_stream.puts e.message
        true
      end

      def configuration
        return @configuration if @configuration

        @configuration = Configuration.new(@out_stream, @error_stream)
        @configuration.parse!(@args)
        Cucumber.logger = @configuration.log
        @configuration
      end

      private
      
      def run_drb_client
        return false unless configuration.drb?
        @drb_output = DRbClient.run(@args, @error_stream, @out_stream, configuration.drb_port)
        true
      rescue DRbClientError => e
        @error_stream.puts "WARNING: #{e.message} Running features locally:"
      end

      def trap_interrupt
        trap('INT') do
          exit!(1) if Cucumber.wants_to_quit
          Cucumber.wants_to_quit = true
          STDERR.puts "\nExiting... Interrupt again to exit immediately."
        end
      end
    end
  end
end
