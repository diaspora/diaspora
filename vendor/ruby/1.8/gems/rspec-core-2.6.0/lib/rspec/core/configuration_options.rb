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
        formatters = options[:formatters] if keys.delete(:formatters)
        keys.each do |key|
          config.send("#{key}=", options[key]) if config.respond_to?("#{key}=")
        end
        if formatters
          formatters.each do |pair|
            config.add_formatter(*pair)
          end
        end
      end

      def drb_argv
        argv = []
        argv << "--color"        if options[:color_enabled]
        argv << "--profile"      if options[:profile_examples]
        argv << "--backtrace"    if options[:full_backtrace]
        argv << "--tty"          if options[:tty]
        argv << "--fail-fast"    if options[:fail_fast]
        argv << "--line_number"  << options[:line_number]             if options[:line_number]
        argv << "--options"      << options[:custom_options_file]     if options[:custom_options_file]
        argv << "--example"      << options[:full_description].source if options[:full_description]
        if options[:filter]
          options[:filter].each_pair do |k, v|
            argv << "--tag" << k.to_s
          end
        end
        if options[:formatters]
          options[:formatters].each do |pair|
            argv << "--format" << pair[0]
            argv << "--out" << pair[1] if pair[1]
          end
        end
        (options[:libs] || []).each do |path|
          argv << "-I" << path
        end
        (options[:requires] || []).each do |path|
          argv << "--require" << path
        end
        argv + options[:files_or_directories_to_run]
      end

      def parse_options
        @options ||= [file_options, command_line_options, env_options].inject {|merged, o| merged.merge o}
      end

    private

      def file_options
        custom_options_file ? custom_options : global_options.merge(local_options)
      end

      def env_options
        ENV["SPEC_OPTS"] ? Parser.parse!(ENV["SPEC_OPTS"].split) : {}
      end

      def command_line_options
        @command_line_options ||= Parser.parse!(@args).merge :files_or_directories_to_run => @args
      end

      def custom_options
        options_from(custom_options_file)
      end

      def local_options
        @local_options ||= options_from(LOCAL_OPTIONS_FILE)
      end

      def global_options
        @global_options ||= options_from(GLOBAL_OPTIONS_FILE)
      end

      def options_from(path)
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

      def custom_options_file
        command_line_options[:custom_options_file]
      end
    end
  end
end
