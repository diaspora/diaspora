require File.dirname(__FILE__) + '/spec_helper'

describe YARD::CodeObjects::Base do
  before { Registry.clear }

  # Fix this
  # it "should not allow empty object name" do
  #   lambda { Base.new(:root, '') }.should raise_error(ArgumentError)
  # end
  
  it "should return a unique instance of any registered object" do
    obj = ClassObject.new(:root, :Me)
    obj2 = ClassObject.new(:root, :Me)
    obj.object_id.should == obj2.object_id
    
    obj3 = ModuleObject.new(obj, :Too)
    obj4 = CodeObjects::Base.new(obj3, :Hello)
    obj4.parent = obj
    
    obj5 = CodeObjects::Base.new(obj3, :hello)
    obj4.object_id.should_not == obj5.object_id
  end

  it "should create a new object if cached object is not of the same class" do
    ConstantObject.new(:root, "MYMODULE").should be_instance_of(ConstantObject)
    ModuleObject.new(:root, "MYMODULE").should be_instance_of(ModuleObject)
    ClassObject.new(:root, "MYMODULE").should be_instance_of(ClassObject)
    YARD::Registry.at("MYMODULE").should be_instance_of(ClassObject)
  end
  
  it "should recall the block if #new is called on an existing object" do
    o1 = ClassObject.new(:root, :Me) do |o|
      o.docstring = "DOCSTRING"
    end
    
    o2 = ClassObject.new(:root, :Me) do |o|
      o.docstring = "NOT_DOCSTRING"
    end
    
    o1.object_id.should == o2.object_id
    o1.docstring.should == "NOT_DOCSTRING"
    o2.docstring.should == "NOT_DOCSTRING"
  end
  
  it "should allow complex name and convert that to namespace" do
    obj = CodeObjects::Base.new(nil, "A::B")
    obj.namespace.path.should == "A"
    obj.name.should == :B
  end
  
  it "should allow namespace to be nil and not register in the Registry" do
    obj = CodeObjects::Base.new(nil, :Me)
    obj.namespace.should == nil
    Registry.at(:Me).should == nil
  end
  
  it "should allow namespace to be a NamespaceObject" do
    ns = ModuleObject.new(:root, :Name)
    obj = CodeObjects::Base.new(ns, :Me)
    obj.namespace.should == ns
  end
  
  it "should allow :root to be the shorthand namespace of `Registry.root`" do
    obj = CodeObjects::Base.new(:root, :Me)
    obj.namespace.should == Registry.root
  end
  
  it "should not allow any other types as namespace" do
    lambda { CodeObjects::Base.new("ROOT!", :Me) }.should raise_error(ArgumentError)
  end
  
  it "should register itself in the registry if namespace is supplied" do
    obj = ModuleObject.new(:root, :Me)
    Registry.at(:Me).should == obj
    
    obj2 = ModuleObject.new(obj, :Too)
    Registry.at(:"Me::Too").should == obj2
  end
  
  it "should set any attribute using #[]=" do
    obj = ModuleObject.new(:root, :YARD)
    obj[:some_attr] = "hello"
    obj[:some_attr].should == "hello"
  end
  
  it "#[]= should use the accessor method if available" do
    obj = CodeObjects::Base.new(:root, :YARD)
    obj[:source] = "hello"
    obj.source.should == "hello"
    obj.source = "unhello"
    obj[:source].should == "unhello"
  end
  
  it "should set attributes via attr= through method_missing" do
    obj = CodeObjects::Base.new(:root, :YARD)
    obj.something = 2
    obj.something.should == 2
    obj[:something].should == 2
  end
  
  it "should exist in the parent's #children after creation" do
    obj = ModuleObject.new(:root, :YARD)
    obj2 = MethodObject.new(obj, :testing)
    obj.children.should include(obj2)
  end
  
  it "should properly re-indent source starting from 0 indentation" do
    obj = CodeObjects::Base.new(nil, :test)
    obj.source = <<-eof
      def mymethod
        if x == 2 &&
            5 == 5
          3 
        else
          1
        end
      end
    eof
    obj.source.should == "def mymethod\n  if x == 2 &&\n      5 == 5\n    3 \n  else\n    1\n  end\nend"
    
    Registry.clear
    Parser::SourceParser.parse_string <<-eof
      def key?(key)
        super(key)
      end
    eof
    Registry.at('#key?').source.should == "def key?(key)\n  super(key)\nend"

    Registry.clear
    Parser::SourceParser.parse_string <<-eof
        def key?(key)
          if x == 2
            puts key
          else
            exit
          end
        end
    eof
    Registry.at('#key?').source.should == "def key?(key)\n  if x == 2\n    puts key\n  else\n    exit\n  end\nend"
  end
  
  it "should not add newlines to source when parsing sub blocks" do
    Parser::SourceParser.parse_string <<-eof
      module XYZ
        module ZYX
          class ABC
            def msg
              hello_world
            end
          end
        end
      end
    eof
    Registry.at('XYZ::ZYX::ABC#msg').source.should == "def msg\n  hello_world\nend"    
  end
  
  it "should handle source for 'def x; end'" do
    Registry.clear
    Parser::SourceParser.parse_string "def x; 2 end"
    Registry.at('#x').source.should == "def x; 2 end"
  end
  
  it "should set file and line information" do
    Parser::SourceParser.parse_string <<-eof
      class X; end
    eof
    Registry.at(:X).file.should == '(stdin)'
    Registry.at(:X).line.should == 1
  end
  
  it "should maintain all file associations when objects are defined multiple times in one file" do
    Parser::SourceParser.parse_string <<-eof
      class X; end
      class X; end
      class X; end
    eof
    
    Registry.at(:X).file.should == '(stdin)'
    Registry.at(:X).line.should == 1
    Registry.at(:X).files.should == [['(stdin)', 1], ['(stdin)', 2], ['(stdin)', 3]]
  end

  it "should maintain all file associations when objects are defined multiple times in multiple files" do
    3.times do |i|
      File.stub!(:read_binary).and_return("class X; end")
      Parser::SourceParser.new.parse("file#{i+1}.rb")
    end
    
    Registry.at(:X).file.should == 'file1.rb'
    Registry.at(:X).line.should == 1
    Registry.at(:X).files.should == [['file1.rb', 1], ['file2.rb', 1], ['file3.rb', 1]]
  end

  it "should prioritize the definition with a docstring when returning #file" do
    Parser::SourceParser.parse_string <<-eof
      class X; end
      class X; end
      # docstring
      class X; end
    eof
    
    Registry.at(:X).file.should == '(stdin)'
    Registry.at(:X).line.should == 4
    Registry.at(:X).files.should == [['(stdin)', 4], ['(stdin)', 1], ['(stdin)', 2]]
  end
  
  describe '#format' do
    it "should send to Templates.render" do
      object = MethodObject.new(:root, :method)
      Templates::Engine.should_receive(:render).with(:x => 1, :object => object)
      object.format :x => 1
    end
  end
  
  describe '#source_type' do
    it "should default source_type to :ruby" do
      object = MethodObject.new(:root, :method)
      object.source_type.should == :ruby
    end
  end
  
  describe '#relative_path' do
    it "should accept a string" do
      YARD.parse_string "module A; class B; end; class C; end; end"
      Registry.at('A::B').relative_path(Registry.at('A::C')).should == 
        Registry.at('A::B').relative_path('A::C')
    end
    
    it "should return full class name when objects share a common class prefix" do
      YARD.parse_string "module User; end; module UserManager; end"
      Registry.at('User').relative_path('UserManager').should == 'UserManager'
      Registry.at('User').relative_path(Registry.at('UserManager')).should == 'UserManager'
    end
    
    it "should return the relative path when they share a common namespace" do
      YARD.parse_string "module A; class B; end; class C; end; end"
      Registry.at('A::B').relative_path(Registry.at('A::C')).should == 'C'
      YARD.parse_string "module Foo; module A; end; module B; def foo; end end end"
      Registry.at('Foo::A').relative_path(Registry.at('Foo::B#foo')).should == 'B#foo'
    end
    
    it "should return the full path if they don't have a common namespace" do
      YARD.parse_string "module A; class B; end; end; module D; class C; end; end"
      Registry.at('A::B').relative_path('D::C').should == 'D::C'
      YARD.parse_string 'module C::B::C; module Apple; end; module Ant; end end'
      Registry.at('C::B::C::Apple').relative_path('C::B::C::Ant').should == 'Ant'
      YARD.parse_string 'module OMG::ABC; end; class Object; end'
      Registry.at('OMG::ABC').relative_path('Object').should == "Object"
      YARD.parse_string("class YARD::Config; MYCONST = 1; end")
      Registry.at('YARD::Config').relative_path('YARD::Config::MYCONST').should == "MYCONST"
    end
    
    it "should return a relative path for class methods" do
      YARD.parse_string "module A; def self.b; end; def self.c; end; end"
      Registry.at('A.b').relative_path('A.c').should == 'c'
      Registry.at('A').relative_path('A.c').should == 'c'
    end

    it "should return a relative path for instance methods" do
      YARD.parse_string "module A; def b; end; def c; end; end"
      Registry.at('A#b').relative_path('A#c').should == '#c'
      Registry.at('A').relative_path('A#c').should == '#c'
    end
    
    it "should return full path if relative path is to parent namespace" do
      YARD.parse_string "module A; module B; end end"
      Registry.at('A::B').relative_path('A').should == 'A'
    end
    
    it "should only return name for relative path to self" do
      YARD.parse_string("class A::B::C; def foo; end end")
      Registry.at('A::B::C').relative_path('A::B::C').should == 'C'
      Registry.at('A::B::C#foo').relative_path('A::B::C#foo').should == '#foo'
    end
  end
  
  describe '#docstring=' do
    it "should convert string into Docstring when #docstring= is set" do
      o = ClassObject.new(:root, :Me) 
      o.docstring = "DOCSTRING"
      o.docstring.should be_instance_of(Docstring)
    end
    
    it "should set docstring to docstring of other object if docstring is '(see Path)'" do
      ClassObject.new(:root, :AnotherObject) {|x| x.docstring = "FOO" }
      o = ClassObject.new(:root, :Me)
      o.docstring = '(see AnotherObject)'
      o.docstring.should == "FOO"
    end

    it "should not copy docstring mid-docstring" do
      doc = "Hello.\n(see file.rb)\nmore documentation"
      o = ClassObject.new(:root, :Me)
      o.docstring = doc
      o.docstring.should == doc
    end
    
    it "should allow extra docstring after (see Path)" do
      ClassObject.new(:root, :AnotherObject) {|x| x.docstring = "FOO" }
      o = ClassObject.new(:root, :Me)
      o.docstring = "(see AnotherObject)\n\nEXTRA\n@api private"
      o.docstring.should == "FOO\n\nEXTRA"
      o.docstring.should have_tag(:api)
    end
  end
  
  describe '#docstring' do
    it "should return empty string if docstring was '(see Path)' and Path is not resolved" do
      o = ClassObject.new(:root, :Me)
      o.docstring = '(see AnotherObject)'
      o.docstring.should == ""
    end
    
    it "should return docstring when object is resolved" do
      o = ClassObject.new(:root, :Me)
      o.docstring = '(see AnotherObject)'
      o.docstring.should == ""
      ClassObject.new(:root, :AnotherObject) {|x| x.docstring = "FOO" }
      o.docstring.should == "FOO"
    end
  end
  
  describe '#add_file' do
    it "should only add a file/line combination once" do
      o = ClassObject.new(:root, :Me)
      o.add_file('filename', 12)
      o.files.should == [['filename', 12]]
      o.add_file('filename', 12)
      o.files.should == [['filename', 12]]
      o.add_file('filename', 40) # different line
      o.files.should == [['filename', 12], ['filename', 40]]
    end
  end
end