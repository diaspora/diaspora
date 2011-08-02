module Sass::Script
  # A SassScript parse node representing a unary operation,
  # such as `-$b` or `not true`.
  #
  # Currently only `-`, `/`, and `not` are unary operators.
  class UnaryOperation < Node
    # @param operand [Script::Node] The parse-tree node
    #   for the object of the operator
    # @param operator [Symbol] The operator to perform
    def initialize(operand, operator)
      @operand = operand
      @operator = operator
      super()
    end

    # @return [String] A human-readable s-expression representation of the operation
    def inspect
      "(#{@operator.inspect} #{@operand.inspect})"
    end

    # @see Node#to_sass
    def to_sass(opts = {})
      operand = @operand.to_sass(opts)
      if @operand.is_a?(Operation) ||
          (@operator == :minus &&
           (operand =~ Sass::SCSS::RX::IDENT) == 0)
        operand = "(#{@operand.to_sass(opts)})"
      end
      op = Lexer::OPERATORS_REVERSE[@operator]
      op + (op =~ /[a-z]/ ? " " : "") + operand
    end

    # Returns the operand of the operation.
    #
    # @return [Array<Node>]
    # @see Node#children
    def children
      [@operand]
    end

    protected

    # Evaluates the operation.
    #
    # @param environment [Sass::Environment] The environment in which to evaluate the SassScript
    # @return [Literal] The SassScript object that is the value of the operation
    # @raise [Sass::SyntaxError] if the operation is undefined for the operand
    def _perform(environment)
      operator = "unary_#{@operator}"
      literal = @operand.perform(environment)
      literal.send(operator)
    rescue NoMethodError => e
      raise e unless e.name.to_s == operator.to_s
      raise Sass::SyntaxError.new("Undefined unary operation: \"#{@operator} #{literal}\".")
    end
  end
end
