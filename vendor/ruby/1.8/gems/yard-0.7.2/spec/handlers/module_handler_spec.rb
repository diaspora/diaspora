require File.dirname(__FILE__) + '/spec_helper'

describe "YARD::Handlers::Ruby::#{LEGACY_PARSER ? "Legacy::" : ""}ModuleHandler" do
  before(:all) { parse_file :module_handler_001, __FILE__ }

  it "should parse a module block" do
    Registry.at(:ModName).should_not == nil
    Registry.at("ModName::OtherModName").should_not == nil
  end
  
  it "should attach docstring" do
    Registry.at("ModName::OtherModName").docstring.should == "Docstring"
  end
  
  it "should handle any formatting" do
    Registry.at(:StressTest).should_not == nil
  end
  
  it "should handle complex module names" do
    Registry.at("A::B").should_not == nil
  end
  
  it "should handle modules in the form ::ModName" do
    Registry.at("Kernel").should_not be_nil
  end
  
  it "should list mixins in proper order" do
    Registry.at('D').mixins.should == [P(:C), P(:B), P(:A)]
  end
  
  it "should create proper module when constant is in namespace" do
    Registry.at('Q::FOO::A').should_not be_nil
  end
end