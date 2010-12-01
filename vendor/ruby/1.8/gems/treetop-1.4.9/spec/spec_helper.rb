require 'rubygems'
require 'benchmark'
require 'spec'
require 'polyglot'

$LOAD_PATH.unshift File.expand_path('../../lib')
require 'treetop'
include Treetop

Spec::Runner.configure do |config|
  config.mock_with :rr
end

module Treetop
  class TreetopExampleGroup < Spec::Example::ExampleGroup
    class << self
      attr_accessor :parser_class_under_test

      def testing_expression(expression_under_test)
        testing_grammar(%{
          grammar Test
            rule expression_under_test
        }+expression_under_test+%{
      end
          end
        }.tabto(0))
      end

      def testing_grammar(grammar_under_test)
        grammar_node = parse_with_metagrammar(grammar_under_test.strip, :grammar)
        parser_code = grammar_node.compile
        class_eval(parser_code)
        self.parser_class_under_test = const_get(grammar_node.parser_name.to_sym)
      end

      def parse_with_metagrammar(input, root)
        parser = Treetop::Compiler::MetagrammarParser.new
        parser.root = root
        node = parser.parse(input)
        raise parser.failure_reason unless node
        node
      end

    end

    attr_reader :parser

    def parse_with_metagrammar(input, root)
      self.class.parse_with_metagrammar(input, root)
    end

    def parser_class_under_test
      self.class.parser_class_under_test
    end

    def parse(input, options = {})
      @parser = parser_class_under_test.new
      unless options[:consume_all_input].nil?
        parser.consume_all_input = options.delete(:consume_all_input)
      end
      result = parser.parse(input, options)
      yield result if block_given?
      result
    end

    def parse_multibyte(input, options = {})
      require 'active_support/all'
      parse(input.mb_chars, options)
    end

    def compiling_grammar(grammar_under_test)
      lambda {
        grammar_node = parse_with_metagrammar(grammar_under_test.strip, :grammar)
        parser_code = grammar_node.compile
        [grammar_node, parser_code]
      }
    end

    def compiling_expression(expression_under_test)
      compiling_grammar(%{
        grammar Test
          rule expression_under_test
            #{expression_under_test}
          end
        end
      }.tabto(0))
    end

    def optionally_benchmark(&block)
      if BENCHMARK
        Benchmark.bm do |x|
          x.report(&block)
        end
      else
        yield
      end
    end

    Spec::Example::ExampleGroupFactory.register(:compiler, self)
    Spec::Example::ExampleGroupFactory.register(:runtime, self)
  end
end

class Symbol
  def to_proc
    lambda do |x|
      x.send(self)
    end
  end unless method_defined?(:to_proc)
end
