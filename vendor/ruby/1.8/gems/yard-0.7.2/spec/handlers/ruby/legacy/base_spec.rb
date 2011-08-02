require File.dirname(__FILE__) + '/../../spec_helper'

include Parser::Ruby::Legacy

describe YARD::Handlers::Ruby::Legacy::Base, "#handles and inheritance" do
  before do
    Handlers::Ruby::Legacy::Base.stub!(:inherited)
    Handlers::Ruby::Legacy::MixinHandler.stub!(:inherited) # fixes a Ruby1.9 issue
    @processor = Handlers::Processor.new(nil, false, :ruby18)
  end
  
  def stmt(string)
    Statement.new(TokenList.new(string))
  end
  
  it "should only handle Handlers inherited from Ruby::Legacy::Base class" do
    class IgnoredHandler < Handlers::Base
      handles "hello"
    end
    class NotIgnoredHandlerLegacy < Handlers::Ruby::Legacy::Base
      handles "hello"
    end
    Handlers::Base.stub!(:subclasses).and_return [IgnoredHandler, NotIgnoredHandlerLegacy]
    @processor.find_handlers(stmt("hello world")).should == [NotIgnoredHandlerLegacy]
  end

  it "should handle a string input" do
    class TestStringHandler < Handlers::Ruby::Legacy::Base
      handles "hello"
    end

    TestStringHandler.handles?(stmt("hello world")).should be_true
    TestStringHandler.handles?(stmt("nothello world")).should be_false
  end

  it "should handle regex input" do
    class TestRegexHandler < Handlers::Ruby::Legacy::Base
      handles /^nothello$/
    end

    TestRegexHandler.handles?(stmt("nothello")).should be_true
    TestRegexHandler.handles?(stmt("not hello hello")).should be_false
  end

  it "should handle token input" do
    class TestTokenHandler < Handlers::Ruby::Legacy::Base
      handles TkMODULE
    end

    TestTokenHandler.handles?(stmt("module")).should be_true
    TestTokenHandler.handles?(stmt("if")).should be_false
  end
  
  it "should parse a do/end or { } block with #parse_block" do
    class MyBlockHandler < Handlers::Ruby::Legacy::Base
      handles /\AmyMethod\b/
      def process
        parse_block(:owner => "test")
      end
    end
    
    class MyBlockInnerHandler < Handlers::Ruby::Legacy::Base
      handles "inner"
      def self.reset; @@reached = false end
      def self.reached?; @@reached ||= false end
      def process; @@reached = true end
    end
    
    Handlers::Base.stub!(:subclasses).and_return [MyBlockHandler, MyBlockInnerHandler]
    Parser::SourceParser.parser_type = :ruby18
    Parser::SourceParser.parse_string "myMethod do inner end"
    MyBlockInnerHandler.should be_reached
    MyBlockInnerHandler.reset
    Parser::SourceParser.parse_string "myMethod { inner }"
    MyBlockInnerHandler.should be_reached
    Parser::SourceParser.parser_type = :ruby
  end
end