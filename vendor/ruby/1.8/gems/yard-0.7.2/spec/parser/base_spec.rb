require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe YARD::Parser::Base do
  describe '#initialize' do
    class MyParser < Parser::Base; def initialize(a, b) end end
    
    it "should take 2 arguments" do
      lambda { YARD::Parser::Base.new }.should raise_error(ArgumentError, 
        /wrong (number|#) of arguments|given 0, expected 2/)
    end
    
    it "should raise NotImplementedError on #initialize" do
      lambda { YARD::Parser::Base.new('a', 'b') }.should raise_error(NotImplementedError)
    end

    it "should raise NotImplementedError on #parse" do
      lambda { MyParser.new('a', 'b').parse }.should raise_error(NotImplementedError)
    end

    it "should raise NotImplementedError on #tokenize" do
      lambda { MyParser.new('a', 'b').tokenize }.should raise_error(NotImplementedError)
    end
  end
end
