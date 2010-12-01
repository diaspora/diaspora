require "rbconfig"

module RSpec
  module Core
    class Configuration
      include RSpec::Core::Hooks

      def self.add_setting(name, opts={})
        if opts[:alias]
          alias_method name, opts[:alias]
          alias_method "#{name}=", "#{opts[:alias]}="
          alias_method "#{name}?", "#{opts[:alias]}?"
        else
          define_method("#{name}=") {|val| settings[name] = val}
          define_method(name)       { settings.has_key?(name) ? settings[name] : opts[:default] }
          define_method("#{name}?") { !!(send name) }
        end
      end

      add_setting :error_stream
      add_setting :output_stream
      add_setting :output, :alias => :output_stream
      add_setting :out, :alias => :output_stream
      add_setting :drb
      add_setting :drb_port
      add_setting :profile_examples
      add_setting :fail_fast, :default => false
      add_setting :run_all_when_everything_filtered
      add_setting :mock_framework, :default => :rspec
      add_setting :expectation_framework, :default => :rspec
      add_setting :filter
      add_setting :exclusion_filter
      add_setting :filename_pattern, :default => '**/*_spec.rb'
      add_setting :files_to_run
      add_setting :include_or_extend_modules
      add_setting :backtrace_clean_patterns
      add_setting :autotest

      def initialize
        @color_enabled = false
        self.include_or_extend_modules = []
        self.files_to_run = []
        self.backtrace_clean_patterns = [
          /\/lib\d*\/ruby\//,
          /bin\//,
          /gems/,
          /spec\/spec_helper\.rb/,
          /lib\/rspec\/(core|expectations|matchers|mocks)/
        ]

        filter_run_excluding(
          :if     => lambda { |value, metadata| metadata.has_key?(:if) && !value },
          :unless => lambda { |value| value }
        )
      end

      # :call-seq:
      #   add_setting(:name)
      #   add_setting(:name, :default => "default_value")
      #   add_setting(:name, :alias => :other_setting)
      #
      # Use this to add custom settings to the RSpec.configuration object.
      #
      #   RSpec.configuration.add_setting :foo
      #
      # Creates three methods on the configuration object, a setter, a getter,
      # and a predicate:
      #
      #   RSpec.configuration.foo=(value)
      #   RSpec.configuration.foo()
      #   RSpec.configuration.foo?() # returns !!foo
      #
      # Intended for extension frameworks like rspec-rails, so they can add config
      # settings that are domain specific. For example:
      #
      #   RSpec.configure do |c|
      #     c.add_setting :use_transactional_fixtures, :default => true
      #     c.add_setting :use_transactional_examples, :alias => :use_transactional_fixtures
      #   end
      #
      # == Options
      #
      # +add_setting+ takes an optional hash that supports the following
      # keys:
      #
      #   :default => "default value"
      #
      # This sets the default value for the getter and the predicate (which
      # will return +true+ as long as the value is not +false+ or +nil+).
      #
      #   :alias => :other_setting
      #
      # Aliases its setter, getter, and predicate, to those for the
      # +other_setting+.
      def add_setting(name, opts={})
        self.class.add_setting(name, opts)
      end

      def puts(message)
        output_stream.puts(message)
      end

      def settings
        @settings ||= {}
      end

      def clear_inclusion_filter # :nodoc:
        self.filter = nil
      end

      def cleaned_from_backtrace?(line)
        backtrace_clean_patterns.any? { |regex| line =~ regex }
      end

      def mock_with(mock_framework)
        settings[:mock_framework] = mock_framework
      end

      def require_mock_framework_adapter
        require case mock_framework.to_s
        when /rspec/i
          'rspec/core/mocking/with_rspec'
        when /mocha/i
          'rspec/core/mocking/with_mocha'
        when /rr/i
          'rspec/core/mocking/with_rr'
        when /flexmock/i
          'rspec/core/mocking/with_flexmock'
        else
          'rspec/core/mocking/with_absolutely_nothing'
        end
      end

      def expect_with(expectation_framework)
        settings[:expectation_framework] = expectation_framework
      end

      def require_expectation_framework_adapter
        require case expectation_framework.to_s
        when /rspec/i
          'rspec/core/expecting/with_rspec'
        else
          raise ArgumentError, "#{expectation_framework.inspect} is not supported"
        end
      end

      def full_backtrace=(bool)
        settings[:backtrace_clean_patterns] = []
      end

      def color_enabled
        @color_enabled && (output_to_tty? || autotest?)
      end

      def color_enabled?
        !!color_enabled
      end

      def color_enabled=(bool)
        return unless bool
        @color_enabled = true
        if bool && ::RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
          using_stdout = settings[:output_stream] == $stdout
          using_stderr = settings[:error_stream]  == $stderr
          begin
            require 'Win32/Console/ANSI'
            settings[:output_stream] = $stdout if using_stdout
            settings[:error_stream]  = $stderr if using_stderr
          rescue LoadError
            warn "You must 'gem install win32console' to use colour on Windows"
            @color_enabled = false
          end
        end
      end

      def libs=(libs)
        libs.map {|lib| $LOAD_PATH.unshift lib}
      end

      def requires=(paths)
        paths.map {|path| require path}
      end

      def debug=(bool)
        return unless bool
        begin
          require 'ruby-debug'
        rescue LoadError
          raise <<-EOM

#{'*'*50}
You must install ruby-debug to run rspec with the --debug option.

If you have ruby-debug installed as a ruby gem, then you need to either
require 'rubygems' or configure the RUBYOPT environment variable with
the value 'rubygems'.
#{'*'*50}
EOM
        end
      end

      def line_number=(line_number)
        filter_run({ :line_number => line_number.to_i }, true)
      end

      def full_description=(description)
        filter_run({ :full_description => /#{description}/ }, true)
      end

      attr_writer :formatter_class

      def formatter_class
        @formatter_class ||= begin
                               require 'rspec/core/formatters/progress_formatter'
                               RSpec::Core::Formatters::ProgressFormatter
                             end
      end

      def formatter=(formatter_to_use)
        self.formatter_class = 
          built_in_formatter(formatter_to_use) ||
          custom_formatter(formatter_to_use) ||
          (raise ArgumentError, "Formatter '#{formatter_to_use}' unknown - maybe you meant 'documentation' or 'progress'?.")
      end

      def formatter
        @formatter ||= formatter_class.new(output)
      end

      def reporter
        @reporter ||= Reporter.new(formatter)
      end

      def files_or_directories_to_run=(*files)
        self.files_to_run = files.flatten.collect do |file|
          if File.directory?(file)
            filename_pattern.split(",").collect do |pattern|
              Dir["#{file}/#{pattern.strip}"]
            end
          else
            if file =~ /(\:(\d+))$/
              self.line_number = $2
              file.sub($1,'')
            else
              file
            end
          end
        end.flatten
      end

      # E.g. alias_example_to :crazy_slow, :speed => 'crazy_slow' defines
      # crazy_slow as an example variant that has the crazy_slow speed option
      def alias_example_to(new_name, extra_options={})
        RSpec::Core::ExampleGroup.alias_example_to(new_name, extra_options)
      end

      # Define an alias for it_should_behave_like that allows different
      # language (like "it_has_behavior" or "it_behaves_like") to be
      # employed when including shared examples.
      #
      # Example:
      #
      #     alias_it_should_behave_like_to(:it_has_behavior, 'has behavior:')
      #
      # allows the user to include a shared example group like:
      #
      #     describe Entity do
      #       it_has_behavior 'sortability' do
      #         let(:sortable) { Entity.new }
      #       end
      #     end
      #
      # which is reported in the output as:
      #
      #     Entity
      #       has behavior: sortability
      #         # sortability examples here
      def alias_it_should_behave_like_to(new_name, report_label = '')
        RSpec::Core::ExampleGroup.alias_it_should_behave_like_to(new_name, report_label)
      end

      def filter_run_including(options={}, force_overwrite = false)
        if filter and filter[:line_number] || filter[:full_description]
          warn "Filtering by #{options.inspect} is not possible since " \
               "you are already filtering by #{filter.inspect}"
        else
          if force_overwrite
            self.filter = options
          else
            self.filter = (filter || {}).merge(options)
          end
        end
      end

      alias_method :filter_run, :filter_run_including

      def filter_run_excluding(options={})
        self.exclusion_filter = (exclusion_filter || {}).merge(options)
      end

      def include(mod, filters={})
        include_or_extend_modules << [:include, mod, filters]
      end

      def extend(mod, filters={})
        include_or_extend_modules << [:extend, mod, filters]
      end

      def configure_group(group)
        modules = {
          :include => [] + group.included_modules,
          :extend  => [] + group.ancestors
        }

        include_or_extend_modules.each do |include_or_extend, mod, filters|
          next unless group.apply?(:all?, filters)
          next if modules[include_or_extend].include?(mod)
          modules[include_or_extend] << mod
          group.send(include_or_extend, mod)
        end
      end

      def configure_mock_framework
        require_mock_framework_adapter
        RSpec::Core::ExampleGroup.send(:include, RSpec::Core::MockFrameworkAdapter)
      end

      def configure_expectation_framework
        require_expectation_framework_adapter
        RSpec::Core::ExampleGroup.send(:include, RSpec::Core::ExpectationFrameworkAdapter)
      end

      def load_spec_files
        files_to_run.map {|f| load File.expand_path(f) }
      end

    private

      def output_to_tty?
        begin
          settings[:output_stream].tty?
        rescue NoMethodError
          false
        end
      end

      def built_in_formatter(key)
        case key.to_s
        when 'd', 'doc', 'documentation', 's', 'n', 'spec', 'nested'
          require 'rspec/core/formatters/documentation_formatter'
          RSpec::Core::Formatters::DocumentationFormatter
        when 'h', 'html'
          require 'rspec/core/formatters/html_formatter'
          RSpec::Core::Formatters::HtmlFormatter
        when 't', 'textmate'
          require 'rspec/core/formatters/text_mate_formatter'
          RSpec::Core::Formatters::TextMateFormatter
        when 'p', 'progress'
          require 'rspec/core/formatters/progress_formatter'
          RSpec::Core::Formatters::ProgressFormatter
        end
      end

      def custom_formatter(formatter_ref)
        if Class === formatter_ref
          formatter_ref
        elsif string_const?(formatter_ref)
          begin
            eval(formatter_ref)
          rescue NameError
            require path_for(formatter_ref)
            eval(formatter_ref)
          end
        end
      end

      def string_const?(str)
        str.is_a?(String) && /\A[A-Z][a-zA-Z0-9_:]*\z/ =~ str
      end

      def path_for(const_ref)
        underscore_with_fix_for_non_standard_rspec_naming(const_ref)
      end

      def underscore_with_fix_for_non_standard_rspec_naming(string)
        underscore(string).sub(%r{(^|/)r_spec($|/)}, '\\1rspec\\2') 
      end

      # activesupport/lib/active_support/inflector/methods.rb, line 48
      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end
    end
  end
end
