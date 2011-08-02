require File.dirname(__FILE__) + '/spec_helper'

describe "YARD::Handlers::Ruby::#{LEGACY_PARSER ? "Legacy::" : ""}PrivateConstantHandler" do
  before(:all) { parse_file :private_constant_handler_001, __FILE__ }

  it "should handle private_constant statement" do
    Registry.at('A::Foo').visibility.should == :private
    Registry.at('A::B').visibility.should == :private
    Registry.at('A::C').visibility.should == :private
  end
  
  it "should make all other constants public" do
    Registry.at('A::D').visibility.should == :public
  end
  
  it "should fail if parameter is not String, Symbol or Constant" do
    undoc_error 'class Foo; private_constant x; end'
    undoc_error 'class Foo; X = 1; private_constant X.new("hi"); end'
  end unless LEGACY_PARSER
  
  it "should fail if constant can't be recognized" do
    undoc_error 'class Foo2; private_constant :X end'
  end
end
