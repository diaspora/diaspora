require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

include YARD::Parser::Ruby::Legacy
include YARD::Parser::Ruby::Legacy::RubyToken

describe YARD::Parser::Ruby::Legacy::TokenList do
  describe  "#initialize / #push" do
    it "should accept a tokenlist (via constructor or push)" do
      lambda { TokenList.new(TokenList.new) }.should_not raise_error(ArgumentError)
      TokenList.new.push(TokenList.new("x = 2")).size.should == 6
    end
  
    it "accept a token (via constructor or push)" do
      lambda { TokenList.new(Token.new(0, 0)) }.should_not raise_error(ArgumentError)
      TokenList.new.push(Token.new(0, 0), Token.new(1, 1)).size.should == 2
    end
  
    it "should accept a string and parse it as code (via constructor or push)" do
      lambda { TokenList.new("x = 2") }.should_not raise_error(ArgumentError)
      x = TokenList.new
      x.push("x", "=", "2")
      x.size.should == 6
      x.to_s.should == "x\n=\n2\n"
    end
  
    it "should not accept any other input" do
      lambda { TokenList.new(:notcode) }.should raise_error(ArgumentError)
    end
  
    it "should not interpolate string data" do
      x = TokenList.new('x = "hello #{world}"')
      x.size.should == 6
      x[4].class.should == TkDSTRING
      x.to_s.should == 'x = "hello #{world}"' + "\n"
    end
  end
  
  describe '#to_s' do
    before do
      @t = TokenList.new
      @t << TkDEF.new(1, 1, "def")
      @t << TkSPACE.new(1, 1)
      @t << TkIDENTIFIER.new(1, 1, "x")
      @t << TkStatementEnd.new(1, 1)
      @t << TkSEMICOLON.new(1, 1) << TkSPACE.new(1, 1)
      @t << TkBlockContents.new(1, 1)
      @t << TkSPACE.new(1, 1) << TkEND.new(1, 1, "end")
      @t[0].set_text "def"
      @t[1].set_text " "
      @t[2].set_text "x"
      @t[4].set_text ";"
      @t[5].set_text " "
      @t[7].set_text " "
      @t[8].set_text "end"
    end
    
    it "should only show the statement portion of the tokens by default" do
      @t.to_s.should == "def x"
    end

    it "should show ... for the block token if all of the tokens are shown" do
      @t.to_s(true).should == "def x; ... end"
    end
    
    it "should ignore ... if show_block = false" do
      @t.to_s(true, false).should == "def x;  end"
    end
  end
end