require File.dirname(__FILE__) + '/spec_helper'

describe "YARD::Handlers::Ruby::#{LEGACY_PARSER ? "Legacy::" : ""}MethodConditionHandler" do
  before(:all) { parse_file :method_condition_handler_001, __FILE__ }
  
  it "should not parse regular if blocks in methods" do
    Registry.at('#b').should be_nil
  end
  
  it "should parse if/unless blocks in the form X if COND" do
    Registry.at('#c').should_not be_nil
    Registry.at('#d').should_not be_nil
  end
end