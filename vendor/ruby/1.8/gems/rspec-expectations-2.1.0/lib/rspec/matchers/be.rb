require 'rspec/matchers/dsl'

RSpec::Matchers.define :be_true do
  match do |actual|
    !!actual
  end
end

RSpec::Matchers.define :be_false do
  match do |actual|
    !actual
  end
end

RSpec::Matchers.define :be_nil do
  match do |actual|
    actual.nil?
  end

  failure_message_for_should do |actual|
    "expected nil, got #{actual.inspect}"
  end

  failure_message_for_should_not do
    "expected not nil, got nil"
  end
end

module RSpec
  module Matchers

    class Be #:nodoc:
      include RSpec::Matchers::Pretty
      
      def initialize(*args, &block)
        @args = args
      end
      
      def matches?(actual)
        @actual = actual
        !!@actual
      end

      def failure_message_for_should
        "expected #{@actual.inspect} to evaluate to true"
      end
      
      def failure_message_for_should_not
        "expected #{@actual.inspect} to evaluate to false"
      end
      
      def description
        "be"
      end

      [:==, :<, :<=, :>=, :>, :===].each do |operator|
        define_method operator do |operand|
          BeComparedTo.new(operand, operator)
        end
      end

    private

      def args_to_s
        @args.empty? ? "" : parenthesize(inspected_args.join(', '))
      end
      
      def parenthesize(string)
        "(#{string})"
      end
      
      def inspected_args
        @args.collect{|a| a.inspect}
      end
      
      def expected_to_sentence
        split_words(@expected)
      end
      
      def args_to_sentence
        to_sentence(@args)
      end
        
    end

    class BeComparedTo < Be

      def initialize(operand, operator)
        @expected, @operator = operand, operator
        @args = []
      end

      def matches?(actual)
        @actual = actual
        @actual.__send__(@operator, @expected)
      end

      def failure_message_for_should
        "expected #{@operator} #{@expected}, got #{@actual.inspect}"
      end
      
      def failure_message_for_should_not
        message = <<-MESSAGE
'should_not be #{@operator} #{@expected}' not only FAILED,
it is a bit confusing.
          MESSAGE
          
        raise message << ([:===,:==].include?(@operator) ?
          "It might be more clearly expressed without the \"be\"?" :
          "It might be more clearly expressed in the positive?")
      end

      def description
        "be #{@operator} #{expected_to_sentence}#{args_to_sentence}"
      end

    end

    class BePredicate < Be

      def initialize(*args, &block)
        @expected = parse_expected(args.shift)
        @args = args
        @block = block
      end
      
      def matches?(actual)
        @actual = actual
        begin
          return @result = actual.__send__(predicate, *@args, &@block)
        rescue NameError => predicate_missing_error
          "this needs to be here or rcov will not count this branch even though it's executed in a code example"
        end

        begin
          return @result = actual.__send__(present_tense_predicate, *@args, &@block)
        rescue NameError
          raise predicate_missing_error
        end
      end
      
      def failure_message_for_should
        "expected #{predicate}#{args_to_s} to return true, got #{@result.inspect}"
      end
      
      def failure_message_for_should_not
        "expected #{predicate}#{args_to_s} to return false, got #{@result.inspect}"
      end

      def description
        "#{prefix_to_sentence}#{expected_to_sentence}#{args_to_sentence}"
      end

    private

      def predicate
        "#{@expected}?".to_sym
      end
      
      def present_tense_predicate
        "#{@expected}s?".to_sym
      end
      
      def parse_expected(expected)
        @prefix, expected = prefix_and_expected(expected)
        expected
      end

      def prefix_and_expected(symbol)
        symbol.to_s =~ /^(be_(an?_)?)(.*)/
        return $1, $3
      end

      def prefix_to_sentence
        split_words(@prefix)
      end

    end

    # :call-seq:
    #   should be_true
    #   should be_false
    #   should be_nil
    #   should be_[arbitrary_predicate](*args)
    #   should_not be_nil
    #   should_not be_[arbitrary_predicate](*args)
    #
    # Given true, false, or nil, will pass if actual value is
    # true, false or nil (respectively). Given no args means
    # the caller should satisfy an if condition (to be or not to be). 
    #
    # Predicates are any Ruby method that ends in a "?" and returns true or false.
    # Given be_ followed by arbitrary_predicate (without the "?"), RSpec will match
    # convert that into a query against the target object.
    #
    # The arbitrary_predicate feature will handle any predicate
    # prefixed with "be_an_" (e.g. be_an_instance_of), "be_a_" (e.g. be_a_kind_of)
    # or "be_" (e.g. be_empty), letting you choose the prefix that best suits the predicate.
    #
    # == Examples 
    #
    #   target.should be_true
    #   target.should be_false
    #   target.should be_nil
    #   target.should_not be_nil
    #
    #   collection.should be_empty #passes if target.empty?
    #   target.should_not be_empty #passes unless target.empty?
    #   target.should_not be_old_enough(16) #passes unless target.old_enough?(16)
    def be(*args)
      args.empty? ?
        Matchers::Be.new : equal(*args)
    end

    # passes if target.kind_of?(klass)
    def be_a(klass)
      be_a_kind_of(klass)
    end
    
    alias_method :be_an, :be_a
  end
end
