require 'drb/drb'

module RSpec
  module Core
    class Runner

      def self.autorun
        return if autorun_disabled? || installed_at_exit? || running_in_drb?
        @installed_at_exit = true
        at_exit { run(ARGV, $stderr, $stdout) ? exit(0) : exit(1) }
      end

      def self.autorun_disabled?
        @autorun_disabled ||= false
      end

      def self.disable_autorun!
        @autorun_disabled = true
      end

      def self.installed_at_exit?
        @installed_at_exit ||= false
      end

      def self.running_in_drb?
        (DRb.current_server rescue false) &&
        !!((DRb.current_server.uri) =~ /druby\:\/\/127.0.0.1\:/)
      end

      def self.trap_interrupt
        trap('INT') do
          exit!(1) if RSpec.wants_to_quit
          RSpec.wants_to_quit = true
          STDERR.puts "\nExiting... Interrupt again to exit immediately."
        end
      end

      def self.run(args, err, out)
        trap_interrupt
        options = ConfigurationOptions.new(args)
        options.parse_options

        if options.options[:drb]
          run_over_drb(options, err, out) || run_in_process(options, err, out)
        else
          run_in_process(options, err, out)
        end
      end

      def self.run_over_drb(options, err, out)
        DRbCommandLine.new(options).run(err, out)
      end

      def self.run_in_process(options, err, out)
        CommandLine.new(options, RSpec::configuration, RSpec::world).run(err, out)
      end

    end

  end
end
