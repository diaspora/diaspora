require File.dirname(__FILE__) + '/spec_helper'
require 'ostruct'

describe "YARD::Handlers::Ruby::#{LEGACY_PARSER ? "Legacy::" : ""}MacroHandler" do
  before(:all) { parse_file :macro_handler_001, __FILE__ }
  
  it "should create a readable attribute when @attribute r is found" do
    obj = Registry.at('Foo#attr1')
    obj.should_not be_nil
    obj.should be_reader
    obj.tag(:return).types.should == ['Numeric']
    Registry.at('Foo#attr1=').should be_nil
  end

  it "should create a writable attribute when @attribute w is found" do
    obj = Registry.at('Foo#attr2=')
    obj.should_not be_nil
    obj.should be_writer
    Registry.at('Foo#attr2').should be_nil
  end
  
  it "should default to readwrite @attribute" do
    obj = Registry.at('Foo#attr3')
    obj.should_not be_nil
    obj.should be_reader
    obj = Registry.at('Foo#attr3=')
    obj.should_not be_nil
    obj.should be_writer
  end
  
  it "should allow @attribute to define alternate method name" do
    Registry.at('Foo#attr4').should be_nil
    Registry.at('Foo#custom').should_not be_nil
  end

  it "should default to creating an instance method for any DSL method with tags" do
    obj = Registry.at('Foo#implicit0')
    obj.should_not be_nil
    obj.docstring.should == "IMPLICIT METHOD!"
    obj.tag(:return).types.should == ['String']
  end
  
  it "should set the method name when using @method" do
    obj = Registry.at('Foo.xyz')
    obj.should_not be_nil
    obj.signature.should == 'def xyz(a, b, c)'
    obj.source.should == 'foo_bar'
    obj.docstring.should == 'The foo method'
  end
  
  it "should create hidden overlaod tag when @method has signature" do
    obj = Registry.at('Foo.xyz')
    obj.docstring.tag(:overload).signature.should == 'xyz(a, b, c)'
    obj.docstring.tag(:overload).object.should == obj
  end
  
  it "should set the method name when using @overload" do
    obj = Registry.at('Foo#qux2')
    obj.should_not be_nil
    obj.signature.should == 'def qux2(a, b, c)'
    obj.source.should == 'something'
    obj.docstring.tag(:overload).name.should == :qux2
    obj.docstring.tag(:overload).object.should == obj
  end

  it "should set the method object when using @overload" do
    obj = Registry.at('Foo#qux')
    obj.should_not be_nil
    obj.signature.should == 'def qux(a, b, c)'
    obj.source.should == 'something :qux'
    obj.docstring.tag(:overload).name.should == :qux
    obj.docstring.tag(:overload).object.should == obj
  end
  
  it "should allow setting of @scope" do
    Registry.at('Foo.xyz').scope.should == :class
  end
  
  it "should allow setting of @visibility" do
    Registry.at('Foo.xyz').visibility.should == :protected
  end
  
  it "should ignore DSL methods without tags" do
    Registry.at('Foo#implicit_invalid').should be_nil
  end

  it "should accept a DSL method without tags if it has hash_flag (##)" do
    Registry.at('Foo#implicit_valid').should_not be_nil
    Registry.at('Foo#implicit_invalid2').should be_nil
  end
 
  it "should allow creation of macros" do
    macro = CodeObjects::MacroObject.find('property')
    macro.should_not be_nil
    macro.should_not be_attached
    macro.method_object.should be_nil
  end
  
  it "should handle macros with no parameters to expand" do
    Registry.at('Foo#none').should_not be_nil
    Registry.at('Baz#none').signature.should == 'def none(foo, bar)'
  end
  
  it "should apply new macro docstrings on new objects" do
    obj = Registry.at('Foo#name')
    obj.should_not be_nil
    obj.source.should == 'property :name, String, :a, :b, :c'
    obj.signature.should == 'def name(a, b, c)'
    obj.docstring.should == 'A property that is awesome.'
    obj.tag(:param).name.should == 'a'
    obj.tag(:param).text.should == 'first parameter'
    obj.tag(:return).types.should == ['String']
    obj.tag(:return).text.should == 'the property name'
  end
  
  it "should allow reuse of named macros" do
    obj = Registry.at('Foo#age')
    obj.should_not be_nil
    obj.source.should == 'property :age, Fixnum, :value'
    obj.signature.should == 'def age(value)'
    obj.docstring.should == 'A property that is awesome.'
    obj.tag(:param).name.should == 'value'
    obj.tag(:param).text.should == 'first parameter'
    obj.tag(:return).types.should == ['Fixnum']
    obj.tag(:return).text.should == 'the property age'
  end
  
  it "should use implicitly named macros" do
    macro = CodeObjects::MacroObject.find('parser')
    macro.macro_data.should == "@method $1(opts = {})\n@return NOTHING!"
    macro.should_not be_nil
    macro.should be_attached
    macro.method_object.should == P('Foo.parser')
    obj = Registry.at('Foo#c_parser')
    obj.should_not be_nil
    obj.docstring.should == ""
    obj.signature.should == "def c_parser(opts = {})"
    obj.docstring.tag(:return).text.should == "NOTHING!"
  end
  
  it "should only use implicit macros on methods defined in inherited hierarchy" do
    Registry.at('Bar#x_parser').should be_nil
    Registry.at('Baz#y_parser').should_not be_nil
  end
  
  it "should handle top-level DSL methods" do
    obj = Registry.at('#my_other_method')
    obj.should_not be_nil
    obj.docstring.should == "Docstring for method"
  end
  
  it "should handle Constant.foo syntax" do
    obj = Registry.at('#beep')
    obj.should_not be_nil
    obj.signature.should == 'def beep(a, b, c)'
  end
end