require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Background #:nodoc:
      include FeatureElement
      attr_reader :feature_elements, :name

      def initialize(comment, line, keyword, name, raw_steps)
        @comment, @line, @keyword, @name, @raw_steps = comment, line, keyword, name, raw_steps
        @feature_elements = []
      end

      def init
        return if @steps
        attach_steps(@raw_steps)
        @steps = StepCollection.new(@raw_steps)
        @step_invocations = @steps.step_invocations(true)
      end

      def step_collection(step_invocations)
        init
        unless(@first_collection_created)
          @first_collection_created = true
          @step_invocations.dup(step_invocations)
        else
          @steps.step_invocations(true).dup(step_invocations)
        end
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        init
        visitor.visit_comment(@comment) unless @comment.empty?
        visitor.visit_background_name(@keyword, @name, file_colon_line(@line), source_indent(first_line_length))
        with_visitor(hook_context, visitor) do
          visitor.step_mother.before(hook_context)
          skip_invoke! if failed?
          visitor.visit_steps(@step_invocations)
          @failed = @step_invocations.detect{|step_invocation| step_invocation.exception || step_invocation.status != :passed }
          visitor.step_mother.after(hook_context) if @failed || @feature_elements.empty?
        end
      end
      
      def with_visitor(scenario, visitor)
        @current_visitor = visitor
        init
        if self != scenario && scenario.respond_to?(:with_visitor)
          scenario.with_visitor(visitor) do
            yield
          end
        else
          yield
        end
      end
      
      def accept_hook?(hook)
        init
        if hook_context != self
          hook_context.accept_hook?(hook)
        else
          # We have no scenarios, just ask our feature
          @feature.accept_hook?(hook)
        end
      end

      def skip_invoke!
        @step_invocations.each{|step_invocation| step_invocation.skip_invoke!}
      end

      def failed?
        @failed
      end

      def hook_context
        @feature_elements.first || self
      end

      def to_sexp
        init
        sexp = [:background, @line, @keyword]
        sexp += [@name] unless @name.empty?
        comment = @comment.to_sexp
        sexp += [comment] if comment
        steps = @steps.to_sexp
        sexp += steps if steps.any?
        sexp
      end

      def fail!(exception)
        @failed = true
        @exception = exception
        @current_visitor.visit_exception(@exception, :failed)        
      end


    end
  end
end
