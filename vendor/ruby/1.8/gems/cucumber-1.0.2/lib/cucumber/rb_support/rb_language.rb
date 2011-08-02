require 'cucumber/core_ext/instance_exec'
require 'cucumber/rb_support/rb_dsl'
require 'cucumber/rb_support/rb_world'
require 'cucumber/rb_support/rb_step_definition'
require 'cucumber/rb_support/rb_hook'
require 'cucumber/rb_support/rb_transform'

module Cucumber
  module RbSupport
    # Raised if a World block returns Nil.
    class NilWorld < StandardError
      def initialize
        super("World procs should never return nil")
      end
    end

    # Raised if there are 2 or more World blocks.
    class MultipleWorld < StandardError
      def initialize(first_proc, second_proc)
        message = "You can only pass a proc to #World once, but it's happening\n"
        message << "in 2 places:\n\n"
        message << first_proc.backtrace_line('World') << "\n"
        message << second_proc.backtrace_line('World') << "\n\n"
        message << "Use Ruby modules instead to extend your worlds. See the Cucumber::RbSupport::RbDsl#World RDoc\n"
        message << "or http://wiki.github.com/cucumber/cucumber/a-whole-new-world.\n\n"
        super(message)
      end
    end

    # The Ruby implementation of the programming language API.
    class RbLanguage
      include LanguageSupport::LanguageMethods
      attr_reader :current_world,
                  :step_definitions

      Gherkin::I18n.code_keywords.each do |adverb|
        RbDsl.alias_adverb(adverb)
        RbWorld.alias_adverb(adverb)
      end

      def initialize(step_mother)
        @step_mother = step_mother
        @step_definitions = []
        RbDsl.rb_language = self
        @world_proc = @world_modules = nil
        enable_rspec_expectations_if_available
      end

      def enable_rspec_expectations_if_available
        begin
          # RSpec >=2.0
          require 'rspec/expectations'
          @rspec_matchers = ::RSpec::Matchers
        rescue LoadError => try_rspec_1_2_4_or_higher
          begin
            require 'spec/expectations'
            require 'spec/runner/differs/default'
            require 'ostruct'
            options = OpenStruct.new(:diff_format => :unified, :context_lines => 3)
            Spec::Expectations.differ = Spec::Expectations::Differs::Default.new(options)
            @rspec_matchers = ::Spec::Matchers
          rescue LoadError => give_up
            @rspec_matchers = Module.new{}
          end
        end
      end

      # Gets called for each file under features (or whatever is overridden
      # with --require).
      def step_definitions_for(rb_file) # Looks Unused - Delete?
        begin
          require rb_file # This will cause self.add_step_definition and self.add_hook to be called from RbDsl
          step_definitions
        rescue LoadError => e
          e.message << "\nFailed to load #{code_file}"
          raise e
        ensure
          @step_definitions = nil
        end
      end
      
      def step_matches(name_to_match, name_to_format)
        @step_definitions.map do |step_definition|
          if(arguments = step_definition.arguments_from(name_to_match))
            StepMatch.new(step_definition, name_to_match, name_to_format, arguments)
          else
            nil
          end
        end.compact
      end

      ARGUMENT_PATTERNS = ['"([^"]*)"', '(\d+)']

      def snippet_text(code_keyword, step_name, multiline_arg_class)
        snippet_pattern = Regexp.escape(step_name).gsub('\ ', ' ').gsub('/', '\/')
        arg_count = 0
        ARGUMENT_PATTERNS.each do |pattern|
          snippet_pattern = snippet_pattern.gsub(Regexp.new(pattern), pattern)
          arg_count += snippet_pattern.scan(pattern).length
        end

        block_args = (0...arg_count).map {|n| "arg#{n+1}"}
        block_args << multiline_arg_class.default_arg_name unless multiline_arg_class.nil?
        block_arg_string = block_args.empty? ? "" : " |#{block_args.join(", ")}|"
        multiline_class_comment = ""
        if(multiline_arg_class == Ast::Table)
          multiline_class_comment = "# #{multiline_arg_class.default_arg_name} is a #{multiline_arg_class.to_s}\n  "
        end

        "#{code_keyword} /^#{snippet_pattern}$/ do#{block_arg_string}\n  #{multiline_class_comment}pending # express the regexp above with the code you wish you had\nend"
      end

      def begin_rb_scenario(scenario)
        create_world
        extend_world
        connect_world(scenario)
      end

      def register_rb_hook(phase, tag_expressions, proc)
        add_hook(phase, RbHook.new(self, tag_expressions, proc))
      end

      def register_rb_transform(regexp, proc)
        add_transform(RbTransform.new(self, regexp, proc))
      end

      def register_rb_step_definition(regexp, proc)
        step_definition = RbStepDefinition.new(self, regexp, proc)
        @step_definitions << step_definition
        step_definition
      end

      def build_rb_world_factory(world_modules, proc)
        if(proc)
          raise MultipleWorld.new(@world_proc, proc) if @world_proc
          @world_proc = proc
        end
        @world_modules ||= []
        @world_modules += world_modules
      end

      def load_code_file(code_file)
        load File.expand_path(code_file) # This will cause self.add_step_definition, self.add_hook, and self.add_transform to be called from RbDsl
      end
      
      protected

      def begin_scenario(scenario)
        begin_rb_scenario(scenario)
      end
      
      def end_scenario
        @current_world = nil
      end

      private

      def create_world
        if(@world_proc)
          @current_world = @world_proc.call
          check_nil(@current_world, @world_proc)
        else
          @current_world = Object.new
        end
      end

      def extend_world
        @current_world.extend(RbWorld)
        @current_world.extend(@rspec_matchers)
        (@world_modules || []).each do |mod|
          @current_world.extend(mod)
        end
      end

      def connect_world(scenario)
        @current_world.__cucumber_step_mother = @step_mother
        @current_world.__natural_language = scenario.language
      end

      def check_nil(o, proc)
        if o.nil?
          begin
            raise NilWorld.new
          rescue NilWorld => e
            e.backtrace.clear
            e.backtrace.push(proc.backtrace_line("World"))
            raise e
          end
        else
          o
        end
      end
    end
  end
end
