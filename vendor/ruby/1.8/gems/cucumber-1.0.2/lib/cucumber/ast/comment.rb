module Cucumber
  module Ast
    # Holds the value of a comment parsed from a feature file:
    #
    #   # Lorem ipsum
    #   # dolor sit amet
    #
    # This gets parsed into a Comment with value <tt>"# Lorem ipsum\n# dolor sit amet\n"</tt>
    #
    class Comment #:nodoc:
      def initialize(value)
        @value = value
      end

      def empty?
        @value.nil? || @value == ""
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        @value.strip.split("\n").each do |line|
          visitor.visit_comment_line(line.strip)
        end
      end
      
      def to_sexp
        (@value.nil? || @value == '') ? nil : [:comment, @value]
      end
    end
  end
end