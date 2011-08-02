require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "YARD::Handlers::Ruby::#{LEGACY_PARSER ? "Legacy::" : ""}ClassHandler" do
  before(:all) { parse_file :class_handler_001, __FILE__ }
  
  it "should parse a class block with docstring" do
    P("A").docstring.should == "Docstring"
  end
  
  it "should handle complex class names" do
    P("A::B::C").should_not == nil
  end
  
  it "should handle the subclassing syntax" do
    P("A::B::C").superclass.should == P(:String)
    P("A::X").superclass.should == Registry.at("A::B::C")
  end
  
  it "should interpret class << self as a class level block" do
    P("A.classmethod1").should_not == nil
  end
  
  it "should interpret class << ClassName as a class level block in ClassName's namespace" do
    P("A::B::C.Hello").should be_instance_of(CodeObjects::MethodObject)
  end
  
  it "should make visibility public when parsing a block" do
    P("A::B::C#method1").visibility.should == :public
  end
  
  it "should set superclass type to :class if it is a Proxy" do
    P("A::B::C").superclass.type.should == :class
  end
  
  it "should look for a superclass before creating the class if it shares the same name" do
    P('B::A').superclass.should == P('A')
  end

  it "should handle class definitions in the form ::ClassName" do
    Registry.at("MyRootClass").should_not be_nil
  end
  
  it "should handle superclass as a constant-style method (camping style < R /path/)" do
    P('Test1').superclass.should == P(:R)
    P('Test2').superclass.should == P(:R)
    P('Test6').superclass.should == P(:NotDelegateClass)
  end
  
  it "should handle superclass with OStruct.new or Struct.new syntax (superclass should be OStruct/Struct)" do
    P('Test3').superclass.should == P(:Struct)
    P('Test4').superclass.should == P(:OStruct)
  end
  
  it "should handle DelegateClass(CLASSNAME) superclass syntax" do
    P('Test5').superclass.should == P(:Array)
  end
  
  it "should handle a superclass of the same name in the form ::ClassName" do
    P('Q::Logger').superclass.should == P(:Logger)
    P('Q::Foo').superclass.should_not == P('Q::Logger')
  end
  
  ["CallMethod('test')", "VSD^#}}", 'not.aclass', 'self'].each do |klass|
    it "should raise an UndocumentableError for invalid class '#{klass}'" do
      with_parser(:ruby18) { undoc_error "class #{klass}; end" }
    end
  end
  
  ['@@INVALID', 'hi', '$MYCLASS', 'AnotherClass.new'].each do |klass|
    it "should raise an UndocumentableError for invalid superclass '#{klass}' but it should create the class." do
      YARD::CodeObjects::ClassObject.should_receive(:new).with(Registry.root, 'A')
      with_parser(:ruby18) { undoc_error "class A < #{klass}; end" }
      Registry.at('A').superclass.should == P(:Object)
    end
  end
  
  ['not.aclass', 'self', 'AnotherClass.new'].each do |klass|
    it "should raise an UndocumentableError if the constant class reference 'class << SomeConstant' does not point to a valid class name" do
      with_parser(:ruby18) do
        undoc_error <<-eof
          CONST = #{klass}
          class << CONST; end
        eof
      end
      Registry.at(klass).should be_nil
    end
  end

  it "should document 'class << SomeConstant' by using SomeConstant's value as a reference to the real class name" do
    Registry.at('String.classmethod').should_not be_nil
  end
  
  it "should allow class << SomeRubyClass to create the class if it does not exist" do
    Registry.at('Symbol.toString').should_not be_nil
  end
  
  it "should document 'class Exception' without running into superclass issues" do
    Parser::SourceParser.parse_string <<-eof
      class Exception
      end
    eof
    Registry.at(:Exception).should_not be_nil
  end
  
  it "should document 'class RT < XX::RT' with proper superclass even if XX::RT is a proxy" do
    Registry.at(:RT).should_not be_nil
    Registry.at(:RT).superclass.should == P('XX::RT')
  end
  
  it "should not overwrite docstring with an empty one" do
    Registry.at(:Zebra).docstring.should == "Docstring 2"
  end
  
  it "should turn 'class Const < Struct.new(:sym)' into class Const with attr :sym" do
    obj = Registry.at("Point")
    obj.should be_kind_of(CodeObjects::ClassObject)
    attrs = obj.attributes[:instance]
    [:x, :y, :z].each do |key|
      attrs.should have_key(key)
      attrs[key][:read].should_not be_nil
      attrs[key][:write].should_not be_nil
    end
  end

  it "should turn 'class Const < Struct.new('Name', :sym)' into class Const with attr :sym" do
    obj = Registry.at("AnotherPoint")
    obj.should be_kind_of(CodeObjects::ClassObject)
    attrs = obj.attributes[:instance]
    [:a, :b, :c].each do |key|
      attrs.should have_key(key)
      attrs[key][:read].should_not be_nil
      attrs[key][:write].should_not be_nil
    end

    Registry.at("XPoint").should be_nil
  end
  
  it "should create a Struct::Name class when class Const < Struct.new('Name', :sym) is found" do
    obj = Registry.at("Struct::XPoint")
    obj.should_not be_nil
  end
  
  it "should attach attribtues to the generated Struct::Name class when Struct.new('Name') is used" do
    obj = Registry.at("Struct::XPoint")
    attrs = obj.attributes[:instance]
    [:a, :b, :c].each do |key|
      attrs.should have_key(key)
      attrs[key][:read].should_not be_nil
      attrs[key][:write].should_not be_nil
    end
  end
  
  it "should use @attr to set attribute descriptions on Struct subclasses" do
    obj = Registry.at("DoccedStruct#input")
    obj.docstring.should == "the input stream"
  end
  
  it "should use @attr to set attribute types on Struct subclasses" do
    obj = Registry.at("DoccedStruct#someproc")
    obj.should_not be_nil
    obj.tag(:return).should_not be_nil
    obj.tag(:return).types.should == ["Proc", "#call"]
  end
  
  it "should default types unspecified by @attr to Object on Struct subclasses" do
    obj = Registry.at("DoccedStruct#mode")
    obj.should_not be_nil
    obj.tag(:return).should_not be_nil
    obj.tag(:return).types.should == ["Object"]
  end
  
  it "should create parameters for writers of Struct subclass's attributes" do
    obj = Registry.at("DoccedStruct#input=")
    obj.tags(:param).size.should == 1
    obj.tag(:param).types.should == ["IO"]
  end
  
  ["SemiDoccedStruct", "NotAStruct"].each do |struct|
    describe("Attributes on a " + (struct == "NotAStruct" ? "class" : "struct")) do
      it "defines both readers and writers when @attr is used on Structs" do
        obj = Registry.at(struct)
        attrs = obj.attributes[:instance]
        attrs[:first][:read].should_not be_nil
        attrs[:first][:write].should_not be_nil
      end
  
      it "defines only a reader when only @attr_reader is used on Structs" do
        obj = Registry.at(struct)
        attrs = obj.attributes[:instance]
        attrs[:second][:read].should_not be_nil
        attrs[:second][:write].should be_nil
      end
  
      it "defines only a writer when only @attr_writer is used on Structs" do
        obj = Registry.at(struct)
        attrs = obj.attributes[:instance]
        attrs[:third][:read].should be_nil
        attrs[:third][:write].should_not be_nil
      end
  
      it "defines a reader with correct return types when @attr_reader is used on Structs" do
        obj = Registry.at("#{struct}#second")
        obj.tag(:return).types.should == ["Fixnum"]
      end
  
      it "defines a writer with correct parameter types when @attr_writer is used on Structs" do
        obj = Registry.at("#{struct}#third=")
        obj.tag(:param).types.should == ["Array"]
      end
  
      it "defines a reader and a writer when both @attr_reader and @attr_writer are used" do
        obj = Registry.at(struct)
        attrs = obj.attributes[:instance]
        attrs[:fourth][:read].should_not be_nil
        attrs[:fourth][:write].should_not be_nil
      end
  
      it "uses @attr_reader for the getter when both @attr_reader and @attr_writer are given" do
        obj = Registry.at("#{struct}#fourth")
        obj.tag(:return).types.should == ["#read"]
      end
  
      it "uses @attr_writer for the setter when both @attr_reader and @attr_writer are given" do
        obj = Registry.at("#{struct}#fourth=")
        obj.tag(:param).types.should == ["IO"]
      end
  
      it "extracts text from @attr_reader" do
        Registry.at("#{struct}#fourth").docstring.should == "returns a proc that reads"
      end
  
      it "extracts text from @attr_writer" do
        Registry.at("#{struct}#fourth=").docstring.should == "sets the proc that writes stuff"
      end
    end
  end
    
  it "should inherit from a regular struct" do
    Registry.at('RegularStruct').superclass.should == P(:Struct)
    Registry.at('RegularStruct2').superclass.should == P(:Struct)
  end
  
  it "should handle inheritance from 'self'" do
    Registry.at('Outer1::Inner1').superclass.should == Registry.at('Outer1')
  end
end