require File.join(File.dirname(__FILE__), "..", "spec_helper")
require 'stringio'

include Handlers

def undoc_error(code)
  lambda { StubbedSourceParser.parse_string(code) }.should raise_error(Parser::UndocumentableError)
end

def with_parser(parser_type, &block)
  tmp = StubbedSourceParser.parser_type
  StubbedSourceParser.parser_type = parser_type
  yield
  StubbedSourceParser.parser_type = tmp
end

class StubbedProcessor < Processor
  def process(statements)
    statements.each_with_index do |stmt, index|
      find_handlers(stmt).each do |handler| 
        handler.new(self, stmt).process
      end
    end
  end
end

class StubbedSourceParser < Parser::SourceParser
  StubbedSourceParser.parser_type = :ruby
  def post_process
    post = StubbedProcessor.new(@file, @load_order_errors, @parser_type, @globals)
    post.process(@parser.enumerator)
  end
end
  