require 'cucumber/constantize'
require 'cucumber/runtime/for_programming_languages'

module Cucumber
  class Runtime
    
    class SupportCode
      
      require 'forwardable'
      class StepInvoker
        include Gherkin::Rubify

        def initialize(support_code)
          @support_code = support_code
        end

        def uri(uri)
        end

        def step(step)
          cucumber_multiline_arg = case(rubify(step.multiline_arg))
          when Gherkin::Formatter::Model::DocString
            step.multiline_arg.value
          when Array
            Ast::Table.new(step.multiline_arg.map{|row| row.cells})
          else
            nil
          end
          @support_code.invoke(step.name, cucumber_multiline_arg) 
        end

        def eof
        end
      end
    
      include Constantize
      
      def initialize(user_interface, configuration={})
        @configuration = Configuration.parse(configuration)
        @runtime_facade = Runtime::ForProgrammingLanguages.new(self, user_interface)
        @unsupported_programming_languages = []
        @programming_languages = []
        @language_map = {}
      end
      
      def configure(new_configuration)
        @configuration = Configuration.parse(new_configuration)
      end
    
      # Invokes a series of steps +steps_text+. Example:
      #
      #   invoke(%Q{
      #     Given I have 8 cukes in my belly
      #     Then I should not be thirsty
      #   })
      def invoke_steps(steps_text, i18n, file_colon_line)
        file, line = file_colon_line.split(':')
        parser = Gherkin::Parser::Parser.new(StepInvoker.new(self), true, 'steps')
        parser.parse(steps_text, file, line.to_i)
      end
      
      # Loads and registers programming language implementation.
      # Instances are cached, so calling with the same argument
      # twice will return the same instance.
      #
      def load_programming_language(ext)
        return @language_map[ext] if @language_map[ext]
        programming_language_class = constantize("Cucumber::#{ext.capitalize}Support::#{ext.capitalize}Language")
        programming_language = programming_language_class.new(@runtime_facade)
        @programming_languages << programming_language
        @language_map[ext] = programming_language
        programming_language
      end
    
      def load_files!(files)
        log.debug("Code:\n")
        files.each do |file|
          load_file(file)
        end
        log.debug("\n")
      end
      
      def load_files_from_paths(paths)
        files = paths.map { |path| Dir["#{path}/**/*"] }.flatten
        load_files! files
      end
    
      def unmatched_step_definitions
        @programming_languages.map do |programming_language| 
          programming_language.unmatched_step_definitions
        end.flatten
      end

      def snippet_text(step_keyword, step_name, multiline_arg_class) #:nodoc:
        load_programming_language('rb') if unknown_programming_language?
        @programming_languages.map do |programming_language|
          programming_language.snippet_text(step_keyword, step_name, multiline_arg_class)
        end.join("\n")
      end
    
      def unknown_programming_language?
        @programming_languages.empty?
      end
    
      def fire_hook(name, *args)
        @programming_languages.each do |programming_language|
          programming_language.send(name, *args)
        end
      end
    
      def around(scenario, block)
        @programming_languages.reverse.inject(block) do |blk, programming_language|
          proc do
            programming_language.around(scenario) do
              blk.call(scenario)
            end
          end
        end.call
      end
      
      def step_definitions
        @programming_languages.map do |programming_language|
          programming_language.step_definitions
        end.flatten
      end
    
      def step_match(step_name, name_to_report=nil) #:nodoc:
        matches = matches(step_name, name_to_report)
        raise Undefined.new(step_name) if matches.empty?
        matches = best_matches(step_name, matches) if matches.size > 1 && guess_step_matches?
        raise Ambiguous.new(step_name, matches, guess_step_matches?) if matches.size > 1
        matches[0]
      end
    
      def invoke(step_name, multiline_argument=nil)
        # It is very important to leave multiline_argument=nil as a vararg. Cuke4Duke needs it that way. 
        begin
          step_match(step_name).invoke(multiline_argument)
        rescue Exception => e
          e.nested! if Undefined === e
          raise e
        end
      end

    private
  
      def guess_step_matches?
        @configuration.guess?
      end
    
      def matches(step_name, name_to_report)
        @programming_languages.map do |programming_language| 
          programming_language.step_matches(step_name, name_to_report).to_a
        end.flatten
      end

      def best_matches(step_name, step_matches) #:nodoc:
        no_groups      = step_matches.select {|step_match| step_match.args.length == 0}
        max_arg_length = step_matches.map {|step_match| step_match.args.length }.max
        top_groups     = step_matches.select {|step_match| step_match.args.length == max_arg_length }

        if no_groups.any?
          longest_regexp_length = no_groups.map {|step_match| step_match.text_length }.max
          no_groups.select {|step_match| step_match.text_length == longest_regexp_length }
        elsif top_groups.any?
          shortest_capture_length = top_groups.map {|step_match| step_match.args.inject(0) {|sum, c| sum + c.to_s.length } }.min
          top_groups.select {|step_match| step_match.args.inject(0) {|sum, c| sum + c.to_s.length } == shortest_capture_length }
        else
          top_groups
        end
      end
    
      def load_file(file)
        if programming_language = programming_language_for(file)
          log.debug("  * #{file}\n")
          programming_language.load_code_file(file)
        else
          log.debug("  * #{file} [NOT SUPPORTED]\n")
        end
      end
    
      def log
        Cucumber.logger
      end
    
      def programming_language_for(step_def_file)
        if ext = File.extname(step_def_file)[1..-1]
          return nil if @unsupported_programming_languages.index(ext)
          begin
            load_programming_language(ext)
          rescue LoadError => e
            log.debug("Failed to load '#{ext}' programming language for file #{step_def_file}: #{e.message}\n")
            @unsupported_programming_languages << ext
            nil
          end
        else
          nil
        end
      end
    
    end
  end
end