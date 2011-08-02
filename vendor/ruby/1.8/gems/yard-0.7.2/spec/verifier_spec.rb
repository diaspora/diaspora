require File.dirname(__FILE__) + '/spec_helper'

describe YARD::Verifier do
  describe '#parse_expressions' do
    it "should create #__execute method" do
      v = Verifier.new("expr1")
      v.should respond_to(:__execute)
    end

    it "should parse @tagname into tag('tagname')" do
      obj = mock(:object)
      obj.should_receive(:tag).with('return')
      Verifier.new('@return').call(obj)
    end

    it "should parse @@tagname into object.tags('tagname')" do
      obj = mock(:object)
      obj.should_receive(:tags).with('return')
      Verifier.new('@@return').call(obj)
    end

    it "should send any missing methods to object" do
      obj = mock(:object)
      obj.should_receive(:has_tag?).with('return')
      Verifier.new('has_tag?("return")').call(obj)
    end

    it "should allow multiple expressions" do
      obj = mock(:object)
      obj.should_receive(:tag).with('return').and_return(true)
      obj.should_receive(:tag).with('param').and_return(false)
      Verifier.new('@return', '@param').call(obj).should == false
    end
  end
  
  describe '#o' do
    it "should alias object to o" do
      obj = mock(:object)
      obj.should_receive(:a).ordered
      Verifier.new('o.a').call(obj)
    end
  end

  describe '#call' do
    it "should mock a nonexistent tag so that exceptions are not raised" do
      obj = mock(:object)
      obj.should_receive(:tag).and_return(nil)
      Verifier.new('@return.text').call(obj).should == false
    end
    
    it "should not fail if no expressions were added" do
      lambda { Verifier.new.call(nil) }.should_not raise_error
    end
    
    it "should always ignore proxy objects and return true" do
      v = Verifier.new('tag(:x)')
      lambda { v.call(P('foo')).should == true }.should_not raise_error
    end
  end
  
  describe '#expressions' do
    it "should maintain a list of all unparsed expressions" do
      Verifier.new('@return.text', '@private').expressions.should == ['@return.text', '@private']
    end
  end

  describe '#expressions=' do
    it "should recompile expressions when attribute is modified" do
      obj = mock(:object)
      obj.should_receive(:tag).with('return')
      v = Verifier.new
      v.expressions = ['@return']
      v.call(obj)
    end
  end
  
  describe '#add_expressions' do
    it "should add new expressions and recompile" do
      obj = mock(:object)
      obj.should_receive(:tag).with('return')
      v = Verifier.new
      v.add_expressions '@return'
      v.call(obj)
    end
  end
end