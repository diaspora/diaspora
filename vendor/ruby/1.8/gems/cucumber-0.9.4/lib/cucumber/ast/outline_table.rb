module Cucumber
  module Ast
    class OutlineTable < Table #:nodoc:
      def initialize(raw, scenario_outline)
        super(raw)
        @scenario_outline = scenario_outline
        @cells_class = ExampleRow
        init
      end

      def init
        create_step_invocations_for_example_rows!(@scenario_outline)
      end

      def to_sexp
        init
        super
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        init
        cells_rows.each_with_index do |row, n|
          if(visitor.configuration.expand?)
            row.accept(visitor)
          else
            visitor.visit_table_row(row)
          end
        end
        nil
      end

      def accept_hook?(hook)
        @scenario_outline.accept_hook?(hook)
      end
      
      def source_tag_names
        @scenario_outline.source_tag_names
      end

      def skip_invoke!
        init
        example_rows.each do |cells|
          cells.skip_invoke!
        end
      end

      def create_step_invocations_for_example_rows!(scenario_outline)
        return if @dunit
        @dunit = true
        example_rows.each do |cells|
          cells.create_step_invocations!(scenario_outline)
        end
      end
      
      def example_rows
        cells_rows[1..-1]
      end

      def visit_scenario_name(visitor, row)
        @scenario_outline.visit_scenario_name(visitor, row)
      end

      def language
        @scenario_outline.language
      end

      class ExampleRow < Cells #:nodoc:        
        class InvalidForHeaderRowError < NoMethodError
          def initialize(*args)
            super 'This is a header row and cannot pass or fail'
          end
        end
        
        attr_reader :scenario_outline # https://rspec.lighthouseapp.com/projects/16211/tickets/342

        def initialize(table, cells)
          super
          @scenario_exception = nil
        end
        
        def source_tag_names
          @table.source_tag_names
        end

        def create_step_invocations!(scenario_outline)
          @scenario_outline = scenario_outline
          @step_invocations = scenario_outline.step_invocations(self)
        end
        
        def skip_invoke!
          @step_invocations.each do |step_invocation|
            step_invocation.skip_invoke!
          end
        end

        def accept(visitor)
          return if Cucumber.wants_to_quit
          visitor.configuration.expand? ? accept_expand(visitor) : accept_plain(visitor)
        end

        def accept_plain(visitor)
          if header?
            @cells.each do |cell|
              cell.status = :skipped_param
              visitor.visit_table_cell(cell)
            end
          else
            visitor.step_mother.with_hooks(self) do
              @step_invocations.each do |step_invocation|
                step_invocation.invoke(visitor.step_mother, visitor.configuration)
                @exception ||= step_invocation.reported_exception
              end

              @cells.each do |cell|
                visitor.visit_table_cell(cell)
              end
              
              visitor.visit_exception(@scenario_exception, :failed) if @scenario_exception
            end
          end
        end

        def accept_expand(visitor)
          if header?
          else
            visitor.step_mother.with_hooks(self) do
              @table.visit_scenario_name(visitor, self)
              @step_invocations.each do |step_invocation|
                step_invocation.invoke(visitor.step_mother, visitor.configuration)
                @exception ||= step_invocation.reported_exception
                step_invocation.visit_step_result(visitor)
              end
            end
          end
        end

        def accept_hook?(hook)
          @table.accept_hook?(hook)
        end
        
        def exception
          @exception || @scenario_exception
        end
        
        def fail!(exception)
          @scenario_exception = exception
        end
        
        # Returns true if one or more steps failed
        def failed?
          raise InvalidForHeaderRowError if header?
          @step_invocations.failed? || !!@scenario_exception
        end

        # Returns true if all steps passed
        def passed?
          !failed?
        end

        # Returns the status
        def status
          return :failed if @scenario_exception
          @step_invocations.status
        end

        def backtrace_line
          @scenario_outline.backtrace_line(name, line)
        end

        def name
          "| #{@cells.collect{|c| c.value }.join(' | ')} |"
        end

        def language
          @table.language
        end

        private

        def header?
          index == 0
        end
      end
    end
  end
end
