require File.dirname(__FILE__) + '/spec_helper'

describe "YARD::Handlers::Ruby::#{LEGACY_PARSER ? "Legacy::" : ""}ExtendHandler" do
  before(:all) { parse_file :extend_handler_001, __FILE__ }

  it "should include modules at class scope" do
    Registry.at(:B).class_mixins.should == [P(:A)]
    Registry.at(:B).instance_mixins.should be_empty
  end

  it "should handle a module extending itself" do
    Registry.at(:C).class_mixins.should == [P(:C)]
    Registry.at(:C).instance_mixins.should be_empty
  end
  
  it "should extend module with correct namespace" do
    Registry.at('Q::R::S').class_mixins.first.path.should == 'A'
  end
  
  it "should not allow extending self if object is a class" do
    undoc_error "class Foo; extend self; end"
  end
end
