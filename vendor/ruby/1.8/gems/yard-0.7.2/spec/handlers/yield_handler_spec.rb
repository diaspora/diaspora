require File.dirname(__FILE__) + '/spec_helper'

describe "YARD::Handlers::Ruby::#{LEGACY_PARSER ? "Legacy::" : ""}YieldHandler" do
  before(:all) { parse_file :yield_handler_001, __FILE__ }
  
  it "should only parse yield blocks in methods" do
    P(:Testing).tag(:yield).should be_nil
    P(:Testing).tag(:yieldparam).should be_nil
  end
  
  it "should handle an empty yield statement" do
    P('Testing#mymethod').tag(:yield).should be_nil
    P('Testing#mymethod').tag(:yieldparam).should be_nil
  end
  
  it "should not document a yield statement in a method with either @yield or @yieldparam" do
    P('Testing#mymethod2').tag(:yield).types.should == ['a', 'b']
    P('Testing#mymethod2').tag(:yield).text.should == "Blah"
    P('Testing#mymethod2').tags(:yieldparam).size.should == 2

    P('Testing#mymethod3').tag(:yield).types.should == ['a', 'b']
    P('Testing#mymethod3').tags(:yieldparam).size.should == 0

    P('Testing#mymethod4').tag(:yieldparam).name.should == '_self'
    P('Testing#mymethod4').tag(:yieldparam).text.should == 'BLAH'
  end
  
  it "should handle any arbitrary yield statement" do
    P('Testing#mymethod5').tag(:yield).types.should == [':a', 'b', '_self', 'File.read(\'file\', \'w\')', 'CONSTANT']
  end
  
  it "should handle parentheses" do
    P('Testing#mymethod6').tag(:yield).types.should == ['b', 'a']
  end
  
  it "should only document the first yield statement in a method (limitation of yield handler)" do
    P('Testing#mymethod7').tag(:yield).types.should == ['a']
  end
  
  it "should handle `self` keyword and list object type as yieldparam for _self" do
    P('Testing#mymethod8').tag(:yield).types.should == ['_self']
    P('Testing#mymethod8').tag(:yieldparam).types.should == ['Testing']
    P('Testing#mymethod8').tag(:yieldparam).text.should == "the object that the method was called on"
  end
  
  it "should handle `super` keyword and document it under _super" do
    P('Testing#mymethod9').tag(:yield).types.should == ['_super']
    P('Testing#mymethod9').tag(:yieldparam).types.should be_nil
    P('Testing#mymethod9').tag(:yieldparam).text.should == "the result of the method from the superclass"
  end
end