module Cucumber
  module Ast
    # Represents an inline argument in a step. Example:
    #
    #   Given the message
    #     """
    #     I like
    #     Cucumber sandwich
    #     """
    #
    # The text between the pair of <tt>"""</tt> is stored inside a PyString,
    # which is yielded to the StepDefinition block as the last argument.
    #
    # The StepDefinition can then access the String via the #to_s method. In the
    # example above, that would return: <tt>"I like\nCucumber sandwich"</tt>
    #
    # Note how the indentation from the source is stripped away.
    #
    class PyString #:nodoc:
      class Builder
        attr_reader :string

        def initialize
          @string = ''
        end

        def py_string(string, line_number)
          @string = string
        end

        def eof
        end
      end

      attr_accessor :file

      def self.default_arg_name
        "string"
      end

      def self.parse(text)
        builder = Builder.new
        lexer = Gherkin::I18nLexer.new(builder)
        lexer.scan(text)
        new(builder.string)
      end

      def initialize(string)
        @string = string
      end

      def to_step_definition_arg
        @string
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        visitor.visit_py_string(@string)
      end
      
      def arguments_replaced(arguments) #:nodoc:
        string = @string
        arguments.each do |name, value|
          value ||= ''
          string = string.gsub(name, value)
        end
        PyString.new(string)
      end

      def has_text?(text)
        @string.index(text)
      end

      # For testing only
      def to_sexp #:nodoc:
        [:py_string, to_step_definition_arg]
      end
    end
  end
end
