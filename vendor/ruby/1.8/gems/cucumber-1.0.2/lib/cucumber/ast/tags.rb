require 'gherkin/tag_expression'

module Cucumber
  module Ast
    class Tags #:nodoc:
      attr_reader :tag_names

      def initialize(line, tag_names)
        @line, @tag_names = line, tag_names
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        @tag_names.each do |tag_name|
          visitor.visit_tag_name(tag_name)
        end
      end

      def accept_hook?(hook)
        Gherkin::TagExpression.new(hook.tag_expressions).eval(@tag_names)
      end

      def to_sexp
        @tag_names.map{|tag_name| [:tag, tag_name]}
      end
    end
  end
end
