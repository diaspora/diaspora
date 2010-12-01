module Cucumber
  module Ast
    class Examples #:nodoc:
      attr_writer :outline_table
      
      def initialize(comment, line, keyword, name, outline_table)
        @comment, @keyword, @name, @outline_table = comment, keyword, name, outline_table
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        visitor.visit_comment(@comment) unless @comment.empty?
        visitor.visit_examples_name(@keyword, @name)
        visitor.visit_outline_table(@outline_table)
      end

      def skip_invoke!
        @outline_table.skip_invoke!
      end

      def each_example_row(&proc)
        @outline_table.cells_rows[1..-1].each(&proc)
      end

      def failed?
        @outline_table.cells_rows[1..-1].select{|row| row.failed?}.any?
      end

      def to_sexp
        sexp = [:examples, @keyword, @name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        sexp += [@outline_table.to_sexp]
        sexp
      end
    end
  end
end
