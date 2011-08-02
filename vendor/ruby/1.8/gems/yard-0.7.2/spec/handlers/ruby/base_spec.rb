require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::Handlers::Ruby::Base, '#valid_handler?' do
  include YARD::Parser::Ruby; YARD::Parser::Ruby::AstNode

  before do
    Handlers::Ruby::Base.stub!(:inherited)
    @processor = Handlers::Processor.new(nil, false, :ruby)
  end
  
  def valid(handler, stmt)
    @processor.find_handlers(stmt).should include(handler)
  end
  
  def invalid(handler, stmt)
    @processor.find_handlers(stmt).should_not include(handler)
  end

  it "should only handle Handlers inherited from Ruby::Base class" do
    class IgnoredHandler < Handlers::Base
      handles :list
    end
    class NotIgnoredHandler < Handlers::Ruby::Base
      handles :list
    end
    Handlers::Base.stub!(:subclasses).and_return [IgnoredHandler, NotIgnoredHandler]
    @processor.find_handlers(s()).should == [NotIgnoredHandler]
  end

  it "should handle string input (matches AstNode#source)" do
    class StringHandler < Handlers::Ruby::Base
      handles "x"
    end
    Handlers::Base.stub!(:subclasses).and_return [StringHandler]
    ast = Parser::Ruby::RubyParser.parse("if x == 2 then true end").ast
    valid StringHandler, ast[0][0][0]
    invalid StringHandler, ast[0][1]
  end
  
  it "should handle symbol input (matches AstNode#type)" do
    class SymbolHandler < Handlers::Ruby::Base
      handles :myNodeType
    end
    Handlers::Base.stub!(:subclasses).and_return [SymbolHandler]
    valid SymbolHandler, s(:myNodeType, s(1, 2, 3))
    invalid SymbolHandler, s(:NOTmyNodeType, s(1, 2, 3))
  end

  it "should handle regex input (matches AstNode#source)" do
    class RegexHandler < Handlers::Ruby::Base
      handles %r{^if x ==}
    end
    Handlers::Base.stub!(:subclasses).and_return [RegexHandler]
    ast = Parser::Ruby::RubyParser.parse("if x == 2 then true end").ast
    valid RegexHandler, ast
    invalid RegexHandler, ast[0][1]
  end

  it "should handle AstNode input (matches AST literally)" do
    class ASTHandler < Handlers::Ruby::Base
      handles s(:var_ref, s(:ident, "hello_world"))
    end
    Handlers::Base.stub!(:subclasses).and_return [ASTHandler]
    valid ASTHandler, s(:var_ref, s(:ident, "hello_world"))
    invalid ASTHandler, s(:var_ref, s(:ident, "NOTHELLOWORLD"))
  end
  
  it "should handle #method_call(:methname) on a valid AST" do
    class MethCallHandler < Handlers::Ruby::Base
      handles method_call(:meth)
    end
    Handlers::Base.stub!(:subclasses).and_return [MethCallHandler]
    ast = Parser::Ruby::RubyParser.parse(<<-"eof").ast
      meth                   # 0
      meth()                 # 1
      meth(1,2,3)            # 2
      meth 1,2,3             # 3
      NotMeth.meth           # 4
      NotMeth.meth { }       # 5
      NotMeth.meth do end    # 6
      NotMeth.meth 1, 2, 3   # 7
      NotMeth.meth(1, 2, 3)  # 8
      NotMeth                # 9
    eof
    (0..8).each do |i|
      valid MethCallHandler, ast[i]
    end
    invalid MethCallHandler, ast[9]
  end
end if HAVE_RIPPER