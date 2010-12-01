module RSpec::Core
  class Parser
    def self.parse!(args)
      new.parse!(args)
    end

    class << self
      alias_method :parse, :parse!
    end

    def parse!(args)
      return {} if args.empty?
      if args.include?("--formatter")
        RSpec.deprecate("the --formatter option", "-f or --format")
        args[args.index("--formatter")] = "--format"
      end
      options = {}
      parser(options).parse!(args)
      options
    end

    alias_method :parse, :parse!

    def parser(options)
      OptionParser.new do |parser|
        parser.banner = "Usage: rspec [options] [files or directories]"

        parser.on('-b', '--backtrace', 'Enable full backtrace') do |o|
          options[:full_backtrace] = true
        end

        parser.on('-c', '--[no-]color', '--[no-]colour', 'Enable color in the output') do |o|
          options[:color_enabled] = o
        end

        parser.on('-d', '--debug', 'Enable debugging') do |o|
          options[:debug] = true
        end

        parser.on('-e', '--example PATTERN', "Run examples whose full descriptions match this pattern",
                "(PATTERN is compiled into a Ruby regular expression)") do |o|
          options[:full_description] = /#{o}/
        end

        parser.on('-f', '--format FORMATTER', 'Choose a formatter',
                '  [p]rogress (default - dots)',
                '  [d]ocumentation (group and example names)',
                '  [h]tml',
                '  [t]extmate',
                '  custom formatter class name') do |o|
          options[:formatter] = o
        end

        parser.on('-o', '--out FILE', 'output to a file instead of STDOUT') do |o|
          options[:output_stream] = File.open(o,'w')
        end

        parser.on_tail('-h', '--help', "You're looking at it.") do
          puts parser
          exit
        end

        parser.on('-I DIRECTORY', 'specify $LOAD_PATH directory (may be used more than once)') do |dir|
          options[:libs] ||= []
          options[:libs] << dir
        end

        parser.on('-l', '--line_number LINE', 'Specify the line number of a single example to run') do |o|
          options[:line_number] = o
        end

        parser.on('-p', '--profile', 'Enable profiling of examples with output of the top 10 slowest examples') do |o|
          options[:profile_examples] = o
        end

        parser.on('-r', '--require PATH', 'Require a file') do |path|
          options[:requires] ||= []
          options[:requires] << path
        end

        parser.on('-v', '--version', 'Show version') do
          puts RSpec::Core::Version::STRING
          exit
        end

        parser.on('-X', '--drb', 'Run examples via DRb') do |o|
          options[:drb] = true
        end

        parser.on('--configure COMMAND', 'Generate configuration files') do |cmd|
          CommandLineConfiguration.new(cmd).run
          exit
        end

        parser.on('--drb-port [PORT]', 'Port to connect to on the DRb server') do |o|
          options[:drb_port] = o.to_i
        end

        parser.on('--autotest') do |o|
          options[:autotest] = true
        end

        parser.on('--fail-fast', 'Use the fail_fast option to tell RSpec to abort the run on first failure.') do |o|
          options[:fail_fast] = true
        end

        parser.on('-t', '--tag TAG[:VALUE]', 'Run examples with the specified tag',
                'To exclude examples, add ~ before the tag (e.g. ~slow)',
                '(TAG is always converted to a symbol)') do |tag|
          filter_type = tag =~ /^~/ ? :exclusion_filter : :filter

          name,value = tag.gsub(/^(~@|~|@)/, '').split(':')
          name = name.to_sym
          value = true if value.nil?

          options[filter_type] ||= {}
          options[filter_type][name] = value
        end
      end
    end
  end
end
