require File.dirname(__FILE__) + '/spec_helper'

describe "YARD::Handlers::Ruby::#{LEGACY_PARSER ? "Legacy::" : ""}AttributeHandler" do
  before(:all) { parse_file :attribute_handler_001, __FILE__ }
  
  def read_write(namespace, name, read, write, scope = :instance)
    rname, wname = namespace.to_s+"#"+name.to_s, namespace.to_s+"#"+name.to_s+"="
    if read
      Registry.at(rname).should be_instance_of(CodeObjects::MethodObject) 
    else
      Registry.at(rname).should == nil
    end
    
    if write
      Registry.at(wname).should be_kind_of(CodeObjects::MethodObject) 
    else
      Registry.at(wname).should == nil
    end     
    
    attrs = Registry.at(namespace).attributes[scope][name]
    attrs[:read].should == (read ? Registry.at(rname) : nil)
    attrs[:write].should == (write ? Registry.at(wname) : nil)
  end
  
  it "should parse attributes inside modules too" do
    Registry.at("A#x=").should_not == nil
  end
  
  it "should parse 'attr'" do
    read_write(:B, :a, true, true)
    read_write(:B, :a2, true, false)
    read_write(:B, "a3", true, false)
  end
  
  it "should parse 'attr_reader'" do
    read_write(:B, :b, true, false)
  end
  
  it "should parse 'attr_writer'" do
    read_write(:B, :e, false, true)
  end
  
  it "should parse 'attr_accessor'" do
    read_write(:B, :f, true, true)
  end
  
  it "should parse a list of attributes" do
    read_write(:B, :b, true, false)
    read_write(:B, :c, true, false)
    read_write(:B, :d, true, false)
  end
  
  it "should have a default docstring if one is not supplied" do
    Registry.at("B#f=").docstring.should_not be_empty
  end
  
  it "should set the correct docstring if one is supplied" do
    Registry.at("B#b").docstring.should == "Docstring"
    Registry.at("B#c").docstring.should == "Docstring"
    Registry.at("B#d").docstring.should == "Docstring"
  end
  
  it "should be able to differentiate between class and instance attributes" do
    P('B').class_attributes[:z][:read].scope.should == :class
    P('B').instance_attributes[:z][:read].scope.should == :instance
  end
  
  it "should respond true in method's #is_attribute?" do
    P('B#a').is_attribute?.should == true
    P('B#a=').is_attribute?.should == true
  end
  
  it "should not return true for #is_explicit? in created methods" do
    Registry.at(:B).meths.each do |meth|
      meth.is_explicit?.should == false
    end
  end
  
  it "should handle attr call with no arguments" do
    lambda { StubbedSourceParser.parse_string "attr" }.should_not raise_error
  end
  
  it "should add existing reader method as part of attr_writer combo" do
    Registry.at('C#foo=').attr_info[:read].should == Registry.at('C#foo')
  end

  it "should add existing writer method as part of attr_reader combo" do
    Registry.at('C#foo').attr_info[:write].should == Registry.at('C#foo=')
  end
  
  it "should maintain visibility for attr_reader" do
    Registry.at('D#parser').visibility.should == :protected
  end
end