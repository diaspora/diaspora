require 'drb/drb'

module RSpec
  module Core
    class Runner

      # Register an at_exit hook that runs the suite.
      def self.autorun
        return if autorun_disabled? || installed_at_exit? || running_in_drb?
        @installed_at_exit = true
        at_exit { exit(run(ARGV, $stderr, $stdout)) }
      end
      AT_EXIT_HOOK_BACKTRACE_LINE = "#{__FILE__}:#{__LINE__ - 2}:in `autorun'"

      def self.disable_autorun!
        @autorun_disabled = true
      end

      def self.autorun_disabled? # :nodoc:
        @autorun_disabled ||= false
      end

      def self.installed_at_exit? # :nodoc:
        @installed_at_exit ||= false
      end

      def self.running_in_drb? # :nodoc:
        (DRb.current_server rescue false) &&
         DRb.current_server.uri =~ /druby\:\/\/127.0.0.1\:/
      end

      def self.trap_interrupt # :nodoc:
        trap('INT') do
          exit!(1) if RSpec.wants_to_quit
          RSpec.wants_to_quit = true
          STDERR.puts "\nExiting... Interrupt again to exit immediately."
        end
      end

      # Run a suite of RSpec examples.
      #
      # This is used internally by RSpec to run a suite, but is available
      # for use by any other automation tool.
      #
      # If you want to run this multiple times in the same process, and you
      # want files like spec_helper.rb to be reloaded, be sure to load `load`
      # instead of `require`.
      #
      # ==== Parameters
      # * +args+ - an array of command-line-supported arguments
      # * +err+ - error stream (Default: $stderr)
      # * +out+ - output stream (Default: $stdout)
      #
      # ==== Returns
      # * +Fixnum+ - exit status code (0/1)
      def self.run(args, err=$stderr, out=$stdout)
        trap_interrupt
        options = ConfigurationOptions.new(args)
        options.parse_options

        if options.options[:drb]
          begin
            run_over_drb(options, err, out)
          rescue DRb::DRbConnError
            err.puts "No DRb server is running. Running in local process instead ..."
            run_in_process(options, err, out)
          end
        else
          run_in_process(options, err, out)
        end
      ensure
        RSpec.reset
      end

      def self.run_over_drb(options, err, out) # :nodoc:
        DRbCommandLine.new(options).run(err, out)
      end

      def self.run_in_process(options, err, out) # :nodoc:
        CommandLine.new(options, RSpec::configuration, RSpec::world).run(err, out)
      end

    end

  end
end
