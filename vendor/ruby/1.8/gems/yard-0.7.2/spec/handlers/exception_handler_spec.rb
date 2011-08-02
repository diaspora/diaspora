require File.dirname(__FILE__) + '/spec_helper'

describe "YARD::Handlers::Ruby::#{LEGACY_PARSER ? "Legacy::" : ""}ExceptionHandler" do
  before(:all) { parse_file :exception_handler_001, __FILE__ }
  
  it "should not document an exception outside of a method" do
    P('Testing').has_tag?(:raise).should == false
  end
  
  it "should document a valid raise" do
    P('Testing#mymethod').tag(:raise).types.should == ['ArgumentError']
  end
  
  it "should only document non-dynamic raises" do
    P('Testing#mymethod2').tag(:raise).should be_nil
    P('Testing#mymethod6').tag(:raise).should be_nil
    P('Testing#mymethod7').tag(:raise).should be_nil
  end
  
  it "should treat ConstantName.new as a valid exception class" do
    P('Testing#mymethod8').tag(:raise).types.should == ['ExceptionClass']
  end
  
  it "should not document a method with an existing @raise tag" do
    P('Testing#mymethod3').tag(:raise).types.should == ['A']
  end

  it "should only document the first raise message of a method (limitation of exception handler)" do
    P('Testing#mymethod4').tag(:raise).types.should == ['A']
  end
  
  it "should handle complex class names" do
    P('Testing#mymethod5').tag(:raise).types.should == ['YARD::Parser::UndocumentableError']
  end
  
  it "should ignore any raise calls on a receiver" do
    P('Testing#mymethod9').tag(:raise).should be_nil
  end
  
  it "should handle raise expressions that are method calls" do
    P('Testing#mymethod10').tag(:raise).should be_nil
    P('Testing#mymethod11').tag(:raise).should be_nil
  end
end