module Cucumber
  module Ast
    class ScenarioOutline #:nodoc:
      include FeatureElement
      
      attr_reader :name

      module ExamplesArray #:nodoc:
        def accept(visitor)
          return if Cucumber.wants_to_quit
          each do |examples|
            visitor.visit_examples(examples)
          end
        end
      end

      # The +example_sections+ argument must be an Array where each element is another array representing
      # an Examples section. This array has 3 elements:
      #
      # * Examples keyword
      # * Examples section name
      # * Raw matrix
      def initialize(background, comment, tags, line, keyword, name, raw_steps, example_sections)
        @background, @comment, @tags, @line, @keyword, @name, @raw_steps, @example_sections = background, comment, tags, line, keyword, name, raw_steps, example_sections
      end

      def add_examples(example_section)
        @example_sections << example_section
      end

      def init
        return if @steps
        attach_steps(@raw_steps)
        @steps = StepCollection.new(@raw_steps)

        @examples_array = @example_sections.map do |example_section|
          examples_comment    = example_section[0]
          examples_line       = example_section[1]
          examples_keyword    = example_section[2]
          examples_name       = example_section[3]
          examples_matrix     = example_section[4]

          examples_table = OutlineTable.new(examples_matrix, self)
          Examples.new(examples_comment, examples_line, examples_keyword, examples_name, examples_table)
        end

        @examples_array.extend(ExamplesArray)

        @background.feature_elements << self if @background
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        visitor.visit_comment(@comment) unless @comment.empty?
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name, file_colon_line(@line), source_indent(first_line_length))
        visitor.visit_steps(@steps)

        skip_invoke! if @background && @background.failed?
        visitor.visit_examples_array(@examples_array) unless @examples_array.empty?
      end

      def fail!(exception)
        # Just a hack for https://rspec.lighthouseapp.com/projects/16211/tickets/413-scenario-outlines-that-fail-with-exception-exit-process
        # Also see http://groups.google.com/group/cukes/browse_thread/thread/41cd567cb9df4bc3
      end

      def skip_invoke!
        @examples_array.each{|examples| examples.skip_invoke!}
        @feature.next_feature_element(self) do |next_one|
          next_one.skip_invoke!
        end
      end

      def step_invocations(cells)
        step_invocations = @steps.step_invocations_from_cells(cells)
        if @background
          @background.step_collection(step_invocations)
        else
          StepCollection.new(step_invocations)
        end
      end

      def each_example_row(&proc)
        @examples_array.each do |examples|
          examples.each_example_row(&proc)
        end
      end

      def visit_scenario_name(visitor, row)
        visitor.visit_scenario_name(
          @feature.language.keywords('scenario')[0],
          row.name, 
          file_colon_line(row.line), 
          source_indent(first_line_length)
        )
      end

      def failed?
        @examples_array.select{|examples| examples.failed?}.any?
      end

      def to_sexp
        init
        sexp = [:scenario_outline, @keyword, @name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        steps = @steps.to_sexp
        sexp += steps if steps.any?
        sexp += @examples_array.map{|e| e.to_sexp}
        sexp
      end
    end
  end
end
