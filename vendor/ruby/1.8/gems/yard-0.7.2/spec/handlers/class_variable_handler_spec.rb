require File.dirname(__FILE__) + '/spec_helper'

describe "YARD::Handlers::Ruby::#{LEGACY_PARSER ? "Legacy::" : ""}ClassVariableHandler" do
  before(:all) { parse_file :class_variable_handler_001, __FILE__ }
  
  it "should not parse class variables inside methods" do
    obj = Registry.at("A::B::@@somevar")
    obj.source.should == "@@somevar = \"hello\""
    obj.value.should == '"hello"'
  end
end