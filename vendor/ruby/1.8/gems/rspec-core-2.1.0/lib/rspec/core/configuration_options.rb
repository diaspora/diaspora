require 'optparse'
# http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html

module RSpec
  module Core

    class ConfigurationOptions
      LOCAL_OPTIONS_FILE  = ".rspec"
      GLOBAL_OPTIONS_FILE = File.join(File.expand_path("~"), ".rspec")

      attr_reader :options

      def initialize(args)
        @args = args
      end

      def configure(config)
        keys = options.keys
        keys.unshift(:requires) if keys.delete(:requires)
        keys.unshift(:libs)     if keys.delete(:libs)
        keys.each do |key|
          config.send("#{key}=", options[key])
        end
      end

      def drb_argv
        argv = []
        argv << "--color"     if options[:color_enabled]
        argv << "--profile"   if options[:profile_examples]
        argv << "--backtrace" if options[:full_backtrace]
        argv << "--autotest"  if options[:autotest]
        argv << "--format"       << options[:formatter]               if options[:formatter]
        argv << "--line_number"  << options[:line_number]             if options[:line_number]
        argv << "--example"      << options[:full_description].source if options[:full_description]
        (options[:libs] || []).each do |path|
          argv << "-I" << path
        end
        (options[:requires] || []).each do |path|
          argv << "--require" << path
        end
        argv + options[:files_or_directories_to_run]
      end

      def parse_options
        @options = begin
                     command_line_options = parse_command_line_options
                     local_options        = parse_local_options(command_line_options)
                     global_options       = parse_global_options
                     env_options          = parse_env_options

                     [global_options, local_options, command_line_options, env_options].inject do |merged, options|
                       merged.merge(options)
                     end
                   end
      end

    private

      def parse_env_options
        ENV["SPEC_OPTS"] ? Parser.parse!(ENV["SPEC_OPTS"].split) : {}
      end

      def parse_command_line_options
        options = Parser.parse!(@args)
        options[:files_or_directories_to_run] = @args
        options
      end

      def parse_local_options(options)
        parse_options_file(local_options_file(options))
      end

      def parse_global_options
        parse_options_file(GLOBAL_OPTIONS_FILE)
      end

      def parse_options_file(path)
        Parser.parse(args_from_options_file(path))
      end
      
      def args_from_options_file(path)
        return [] unless File.exist?(path)
        config_string = options_file_as_erb_string(path)
        config_string.split(/\n+/).map {|l| l.split}.flatten
      end
      
      def options_file_as_erb_string(path)
        require 'erb'
        ERB.new(IO.read(path)).result(binding)
      end

      def local_options_file(options)
        return options[:options_file] if options[:options_file]
        LOCAL_OPTIONS_FILE
      end
    end
  end
end
