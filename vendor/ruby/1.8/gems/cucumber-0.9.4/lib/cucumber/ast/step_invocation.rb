require 'cucumber/errors'
require 'cucumber/step_match'
require 'cucumber/ast/table'
require 'gherkin/rubify'

module Cucumber
  module Ast
    class StepInvocation #:nodoc:
      include Gherkin::Rubify

      BACKTRACE_FILTER_PATTERNS = [
        /vendor\/rails|lib\/cucumber|bin\/cucumber:|lib\/rspec|gems\//
      ]

      attr_writer :step_collection, :background
      attr_reader :name, :matched_cells, :status, :reported_exception
      attr_accessor :exception

      class << self
        SEVERITY = [:passed, :undefined, :pending, :skipped, :failed]
        def worst_status(statuses)
          SEVERITY[statuses.map{|status| SEVERITY.index(status)}.max]
        end
      end

      def initialize(step, name, multiline_arg, matched_cells)
        @step, @name, @multiline_arg, @matched_cells = step, name, multiline_arg, matched_cells
        status!(:skipped)
        @skip_invoke = @exception = @step_match = @different_table = @reported_exception = @background = nil
      end

      def background?
        @background
      end

      def skip_invoke!
        @skip_invoke = true
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        invoke(visitor.step_mother, visitor.configuration)
        visit_step_result(visitor)
      end

      def visit_step_result(visitor)
        visitor.visit_step_result(
          keyword,
          @step_match,
          (@different_table || @multiline_arg),
          @status,
          @reported_exception,
          source_indent,
          @background
        )
      end

      def invoke(step_mother, configuration)
        find_step_match!(step_mother, configuration)
        unless @skip_invoke || configuration.dry_run? || @exception || @step_collection.exception
          @skip_invoke = true
          begin
            @step_match.invoke(@multiline_arg)
            step_mother.after_step
            status!(:passed)
          rescue Pending => e
            failed(configuration, e, false)
            status!(:pending)
          rescue Undefined => e
            failed(configuration, e, false)
            status!(:undefined)
          rescue Cucumber::Ast::Table::Different => e
            @different_table = e.table
            failed(configuration, e, false)
            status!(:failed)
          rescue Exception => e
            failed(configuration, e, false)
            status!(:failed)
          end
        end
      end

      def find_step_match!(step_mother, configuration)
        return if @step_match
        begin
          @step_match = step_mother.step_match(@name)
        rescue Undefined => e
          failed(configuration, e, true)
          status!(:undefined)
          @step_match = NoStepMatch.new(@step, @name)
        rescue Ambiguous => e
          failed(configuration, e, false)
          status!(:failed)
          @step_match = NoStepMatch.new(@step, @name)
        end
        step_mother.step_visited(self)
      end

      def failed(configuration, e, clear_backtrace)
        e = filter_backtrace(e)
        e.set_backtrace([]) if clear_backtrace
        e.backtrace << @step.backtrace_line unless @step.backtrace_line.nil?
        @exception = e
        if(configuration.strict? || !(Undefined === e) || e.nested?)
          @reported_exception = e
        else
          @reported_exception = nil
        end
      end

      PWD_PATTERN = /#{Regexp.escape(Dir.pwd)}\//m

      def filter_backtrace(e)
        return e if Cucumber.use_full_backtrace
        (e.backtrace || []).each{|line| line.gsub!(PWD_PATTERN, "./")}
        
        filtered = (e.backtrace || []).reject do |line|
          BACKTRACE_FILTER_PATTERNS.detect { |p| line =~ p }
        end
        
        if Cucumber::JRUBY && e.class.name == 'NativeException'
          # JRuby's NativeException ignores #set_backtrace.
          # We're fixing it.
          e.instance_eval do
            def set_backtrace(backtrace)
              @backtrace = backtrace
            end

            def backtrace
              @backtrace
            end
          end
        end
        e.set_backtrace(filtered)
        e
      end

      def status!(status)
        @status = status
        @matched_cells.each do |cell|
          cell.status = status
        end
      end

      def previous
        @step_collection.previous_step(self)
      end

      def actual_keyword
        repeat_keywords = rubify([language.keywords('but'), language.keywords('and')]).flatten.uniq.reject{|kw| kw == '* '}
        if repeat_keywords.index(@step.keyword) && previous
          previous.actual_keyword
        else
          keyword == '* ' ? language.code_keywords.first : keyword
        end
      end

      def source_indent
        @step.feature_element.source_indent(text_length)
      end

      def text_length
        @step.text_length(@name)
      end

      def keyword
        @step.keyword
      end

      def multiline_arg
        @step.multiline_arg
      end

      def file_colon_line
        @step.file_colon_line
      end

      def dom_id
        @step.dom_id
      end

      def backtrace_line
        @step.backtrace_line
      end

      def language
        @step.language
      end

      def to_sexp
        [:step_invocation, @step.line, @step.keyword, @name, (@multiline_arg.nil? ? nil : @multiline_arg.to_sexp)].compact
      end
    end
  end
end
