begin
  require 'v8'
rescue LoadError
  gem 'therubyracer', '~> 0.7.1'
  require 'v8'
end

require 'cucumber/js_support/js_snippets'

module Cucumber
  module JsSupport

    def self.argument_safe_string(string)
      arg_string = string.to_s.gsub(/[']/, '\\\\\'')
      arg_string.gsub("\n", '\n')
    end

    class JsWorld
      def initialize
        @world = V8::Context.new
      end

      def execute(js_function, args=[])
        js_function.call(*args)
      end

      def method_missing(method_name, *args)
        @world.send(method_name, *args)
      end
    end

    class JsStepDefinition
      def initialize(js_language, regexp, js_function)
        @js_language, @regexp, @js_function = js_language, regexp.to_s, js_function
      end

      def invoke(args)
        args = @js_language.execute_transforms(args)
        @js_language.current_world.execute(@js_function, args)
      end

      def regexp_source
        @regexp.inspect
      end

      def arguments_from(step_name)
        matches = eval_js "#{@regexp}.exec('#{step_name}')"
        if matches
          matches.to_a[1..-1].map do |match|
            JsArg.new(match)
          end
        end
      end

      def file_colon_line
        # Not possible yet to get file/line of js function with V8/therubyracer
        ""
      end
    end

    class JsHook
      def initialize(js_language, tag_expressions, js_function)
        @js_language, @tag_expressions, @js_function = js_language, tag_expressions, js_function
      end

      def tag_expressions
        @tag_expressions
      end

      def invoke(location, scenario)
        @js_language.current_world.execute(@js_function)
      end
    end

    class JsTransform
      def initialize(js_language, regexp, js_function)
        @js_language, @regexp, @js_function = js_language, regexp.to_s, js_function
      end

      def match(arg)
        arg = JsSupport.argument_safe_string(arg)
        matches = (eval_js "#{@regexp}.exec('#{arg}');").to_a
        matches.empty? ? nil : matches[1..-1]
      end

      def invoke(arg)
        @js_function.call([arg])
      end
    end

    class JsArg
      def initialize(arg)
        @arg = arg
      end

      def val
        @arg
      end

      def byte_offset
      end
    end

    class JsLanguage
      include LanguageSupport::LanguageMethods
      include JsSnippets

      def initialize(runtime)
        @step_definitions = []
        @world = JsWorld.new
        @runtime = runtime

        @world["jsLanguage"] = self
        @world.load(File.dirname(__FILE__) + '/js_dsl.js')
      end

      def load_code_file(js_file)
        @world.load(js_file)
      end

      def world(js_files)
        js_files.each do |js_file|
          load_code_file("#{path_to_load_js_from}#{js_file}")
        end
      end

      def alias_adverbs(adverbs)
      end

      def begin_scenario(scenario)
        @language = scenario.language
      end

      def end_scenario
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

      def add_step_definition(regexp, js_function)
        @step_definitions << JsStepDefinition.new(self, regexp, js_function)
      end

      #TODO: support multiline arguments when calling steps from within steps
      def execute_step_definition(name, multiline_argument = nil)
        @runtime.step_match(name).invoke(multiline_argument)
      end

      def register_js_hook(phase, tag_expressions, js_function)
        add_hook(phase, JsHook.new(self, tag_expressions, js_function))
      end

      def register_js_transform(regexp, js_function)
        add_transform(JsTransform.new(self, regexp, js_function))
      end

      def current_world
        @world
      end

      def steps(steps_text, file_colon_line)
        @runtime.invoke_steps(steps_text, @language, file_colon_line)
      end

      private
      def path_to_load_js_from
        paths = @runtime.features_paths
        if paths.empty?
          '' # Using rake
        else
          path = paths[0][/(^.*\/?features)/, 0]
          path ? "#{path}/../" : '../'
        end
      end

    end
  end
end
